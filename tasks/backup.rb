#!/opt/puppetlabs/puppet/bin/ruby
require "fileutils"
require "open3"
require "json"
# Backups up the postgresql database and docker volumes of a CD4PE installation
# These files are dropped in the backup directory using a timestamped filename
# to ensure uniqueness.  This directory is then tarred up afterwards and the name 
# handed back to the caller.
#
# @param [String] backup_dir The absolute path to the directory where the backup will be stored
# @return [Hash] 
#   backup_archive => The basename of the zip containing the backup
#   error => The error message if the task fails
#   message => A message describing the failure result of the task

# Fails the task, returning an error object for the caller
# @param [String] message The detailed error message to return to the caller
# @param [String] error The error from the function that failed
# @param [String] working_dir The working directory to clean up
# @return [Hash] 
def fail_task(message, error, working_dir)
  FileUtils.rm_rf(working_dir) if File.directory?(working_dir)
  ret = { 
    'backup_archive' => '',
    'message' => message,
    'error' => error,
  }
  puts ret.to_json
  exit 1
end

# Backs up the postgresql database to a file in the working directory
# We split things up to increase speed and reduce memory usage.  We use pg_dumpall
# to backup the globals and then pg_dump to backup the individual databases.
# Using pg_dump allows us to parallelize the restore process using the -j flag.
# @param [String] working_dir The full path to the directory where the backup is being built
# @param [String] params The parameters passed into the task
# @return nothing
def backup_database(working_dir, params)
  container = params['database_info']['container_name']
  pgdumpall = '/opt/bitnami/postgresql/bin/pg_dumpall'
  pg_flags = "--username #{params['database_info']['database_user']} --globals-only"
  runtime = params['runtime']
  image = params['image']
  pg_command = "#{runtime} exec #{container} #{pgdumpall} #{pg_flags}"
  
  # use pg_dumpall to backup the --globals-only
  Open3.popen3(pg_command) do |stdin, stdout, stderr, wait_thr|
    pid = wait_thr.pid
    stdin.close
    File.write("#{working_dir}/pg_globals.sql", stdout.read)
    exit_status = wait_thr.value
    if !exit_status.success?
      fail_task('Backup of database globals failed', stderr, working_dir)
    end
  end

  # use pg_dump -Fc to backup the databases
  ['cd4pe','query'].each do |db|
    pgdump = '/opt/bitnami/postgresql/bin/pg_dump'
    pg_flags = "--username #{params['database_info']['database_user']} --clean --format=custom #{db}"
    pg_command = "#{runtime} exec #{container} #{pgdump} #{pg_flags}"
    Open3.popen3(pg_command) do |stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid
      stdin.close
      File.write("#{working_dir}/pg_#{db}.dump", stdout.read)
      exit_status = wait_thr.value
      if !exit_status.success?
        fail_task('Backup of cd4pe database failed', stderr, working_dir)
      end
    end
  end
end

# Backs up the docker volumes to the working directory
# @param [String] working_dir The full path to the directory where the backup is being built
# @param [String] params The parameters passed into the task
# @return [Hash] Of the form:
#   'name' => The name of the volume
#   'container' => The name of the container the volume is attached to
#   'directory' => The directory inside the container where the volume is mounted
# Follows the recommended way of backing up volumes from https://docs.docker.com/storage/volumes/#restore-volume-from-a-backup
# which is to spin up a second container sharing the volume and copy the data out of it.
def backup_volumes(working_dir, params)
  runtime = params['runtime']
  volume_backup_dir = "#{working_dir}/volumes"
  FileUtils.mkdir_p volume_backup_dir
  volume_metadata = params['volumes'].map do |volume|
    mount_data, mount_data_error, mount_data_status = Open3.capture3("#{runtime} container inspect --format='{{json .Mounts}}' #{volume['container']}")
    if !mount_data_status.success?
      fail_task("Failed to get mount data for volume '#{volume['name']}' in container '#{volume['name']}'", mount_data_error, working_dir)
    end
    mounts = JSON.parse(mount_data)
    volume_directory = Hash(mounts.select { |mount| mount['Name'] == volume['name'] }[0])['Destination']
    docker_command = "#{runtime} run --rm --entrypoint '' --volumes-from #{volume['container']} --volume #{volume_backup_dir}:/backup"
    tar_command = "tar --directory #{volume_directory} --create --file /backup/#{volume['container']}-#{volume['name']}.backup.tar ."
    _, backup_error, backup_status = Open3.capture3("#{docker_command} #{params['image']} #{tar_command}")
    # Tar returns 1 if files changed during the backup, which we can ignore. The token shouldn't change over time, 
    # and missing log lines doesn't seem important enough to justify re-try logic.
    if backup_status.exitstatus > 1
      fail_task("Failed to archive files for volume '#{volume['name']}' in container '#{volume['container']}'", backup_error, working_dir)
    end
    {
      'name'      => volume['name'],
      'container' => volume['container'],
      'directory' => volume_directory,
    }
  end
end

params = JSON.parse(STDIN.read)

# Set up working directory
timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
timestamp_directory = "cd4pe-backup-#{timestamp}"
working_dir = "#{params['backup_dir']}/#{timestamp_directory}"
begin
  FileUtils.mkdir_p "#{working_dir}"
rescue => e
  fail_task('Failed to create working directory', e.message, working_dir)
end

backup_database(working_dir, params)

volume_metadata = backup_volumes(working_dir, params)

# Write out metadata file
metadata = {
  'backup_version' => 'v1',
  'version'        => params['version'],
  'volumes'        => volume_metadata,
}
File.write("#{working_dir}/metadata.json", JSON.pretty_generate(metadata))

# Zip up the backup directory and delete it
# Elected to use zip instead of tar/gzip because it is dramatically faster at extracting single files, which
# is a crucial part of the list_backups plan.  The tradeoff is that zip is slightly less efficient compressing
# smaller backups.  However, customers will not have small backups for long, as the database grows fairly quickly,
# and compression ratios for larger backups were similar if not better than tar/gzip.
Dir.chdir(params['backup_dir'])
_, error, status = Open3.capture3("zip --quiet --recurse-paths #{timestamp_directory} #{timestamp_directory}")
if !status.success?
  fail_task("Failed to create zip archive '#{working_dir}.zip'", error, working_dir)
end
FileUtils.rm_rf(working_dir) if File.directory?(working_dir)

# Return output to caller
output = { 
  'backup_archive' => "#{working_dir}.zip",
  'message'        => 'Backup completed successfully',
  'error'          => '',
}
puts output.to_json
