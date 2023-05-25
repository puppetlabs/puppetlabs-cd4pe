#!/opt/puppetlabs/puppet/bin/ruby
require "fileutils"
require "open3"
require "json"
# Restores the postgresql database and docker volumes of a CD4PE installation
# The data is stored in the backup_dir in a zip archive.  We use the metadata
# file from the backup_archive to determine which volumes to restore and where
# to put the data.
#
# @return [Hash] 
#   error => The error message if the task fails
#   message => A message describing the result of the task
#   warnings => An array of warnings encountered during the restore process

# Fails the task, returning an error object for the caller
# @param [String] message The detailed error message to return to the caller
# @param [String] error The error from the function that failed
# @param [String] working_dir The working directory to clean up
# @return [Hash] 
def fail_task(message, error, backup_dir = "")
  FileUtils.rm_rf(backup_dir) unless backup_dir.empty?
  ret = { 
    'message' => message,
    'error' => error,
    'warnings' => '',
  }
  puts ret.to_json
  exit 1
end

# Using the image passed into the task, copy the src file from the backup_dir
# into the container at the dest path.  This helper function is used to implement
# the recommended way of importing data into a container's volume.
# See https://docs.docker.com/storage/volumes/#restore-volume-from-a-backup
# @param [String] src The absolute path to the file to copy on the host filesystem
# @param [String] volume_name The name of the volume to copy the file into 
# @param [String] runtime The runtime in use
# @param [String] image The base image to use to do the copy
# @return [Hash] A hash with the stdout, stderr, and success status of the copy
# @example copy_file_into_volume('/tmp/cd4pe-backup-2023-05-01-22-46/postgres.sql', 'pipelinesinfra-logs', 'docker', 'ubuntu')
def copy_file_into_volume(src, volume_name, runtime, image)
  local_directory = File.dirname(src)
  local_file = File.basename(src)
  flags = "--rm --entrypoint '' --volume #{local_directory}:/src --volume #{volume_name}:/dest"
  command = "cp /src/#{local_file} /dest/#{local_file}"
  stdout, stderr, status = Open3.capture3("#{runtime} run #{flags} #{image} #{command}")
  {
    'output'     => stdout,
    'error'      => stderr,
    'successful' => status.success?
  }
end

# Extracts the tar archive located in the given volume
# @param [String] file The tar archive to extract
# @param [String] volume_name The name of the volume containing the tar archive
# @param [String] runtime The runtime in use
# @param [String] image The base image to use to do the copy
# @return [Hash] A hash with the stdout, stderr, and success status of the tar command
# @example extract_volume_archive('pipelinesinfra-cd4pe-query-service-token.backup.tar', 'pipelinesinfra-logs', 'docker', 'ubuntu')
def extract_volume_archive(file, volume_name, runtime, image)
  flags = "--rm --entrypoint '' --volume #{volume_name}:/dest"
  command = "tar --directory /dest --extract --file /dest/#{file}"
  stdout, stderr, status = Open3.capture3("#{runtime} run #{flags} #{image} #{command}")
  {
    'output'     => stdout,
    'error'      => stderr,
    'successful' => status.success?
  }
end

# Deletes all files from the given volume
# @param [String] volume_name The name of the volume
# @param [String] runtime The runtime in use
# @param [String] image The base image to use to do the copy
# @return [Hash] A hash with the stdout, stderr, and success status of the tar command
# @example delete_all_files_from_volume('pipelinesinfra-logs', 'docker', 'ubuntu')
def delete_all_files_from_volume(volume_name, runtime, image)
  flags = "--rm --entrypoint '' --volume #{volume_name}:/dest"
  command = "bash -c 'rm /dest/*'"
  stdout, stderr, status = Open3.capture3("#{runtime} run #{flags} #{image} #{command}")
  {
    'output'     => stdout,
    'error'      => stderr,
    'successful' => status.success?
  }
end

# Delete a file from the given volume
# @param [String] file The file to delete
# @param [String] volume_name The name of the volume
# @param [String] runtime The runtime in use
# @param [String] image The base image to use to do the copy
# @return [Hash] A hash with the stdout, stderr, and success status of the tar command
# @example delete_file_from_volume('pipelinesinfra-cd4pe-query-service-token.backup.tar', 'pipelinesinfra-logs', 'docker', 'ubuntu')
def delete_file_from_volume(file, volume_name, runtime, image)
  flags = "--rm --entrypoint '' --volume #{volume_name}:/dest"
  command = "rm /dest/#{file}"
  stdout, stderr, status = Open3.capture3("#{runtime} run #{flags} #{image} #{command}")
  {
    'output'     => stdout,
    'error'      => stderr,
    'successful' => status.success?
  }
end

# Extracts the zip archive containing the backup
# @param [String] archive The zip archive to extract
# @return nothing
def extract_backup(archive)
  dir = File.dirname(archive)
  basename = File.basename(archive)
  Dir.chdir(dir)
  _, error, status = Open3.capture3("unzip #{basename}")
  if !status.success?
    fail_task("Failed to open backup file '#{archive}' on target host.'", error)
  end
end

# Restores the postgresql database from the backup
# Uses psql to restore the globals and pg_restore to restore the databases
# @param [String] backup_dir The full path to the directory containing the backup
# @param [String] params The parameters passed into the task
# @return nothing
def restore_database(backup_dir, params)
  runtime = params['runtime']
  image = params['image']

  # restore the globals
  container = params['database_info']['container_name']
  psql = '/opt/bitnami/postgresql/bin/psql'
  db_user = params['database_info']['database_user']
  pg_command = "#{psql} --username #{db_user} --quiet postgres"
  File.open("#{backup_dir}/pg_globals.sql", 'r') do |sql_file|
    _, stderr, status = Open3.capture3("#{runtime} exec --interactive #{container} #{pg_command}", :stdin_data => sql_file.read)
    if !status.success?
      fail_task('Restore of database globals failed', stderr, backup_dir)
    end
  end

  # We can't use --jobs unless this pulls from a file rather than stdin
  # so we copy the files into the volume and run pg_restore
  volume_dir = '/bitnami/postgresql'
  copy_flags = "--rm --entrypoint '' --volumes-from #{container} --volume #{backup_dir}:/backup"
  copy_command = "cp /backup/pg_cd4pe.dump /backup/pg_query.dump #{volume_dir}"
  _, copy_backup_stderr, copy_backup_status = Open3.capture3("#{runtime} run #{copy_flags} #{image} #{copy_command}")
  if !copy_backup_status.success?
    fail_task("Failed to copy database backups into container on target host.", copy_backup_stderr, backup_dir)
  end

  pgrestore = '/opt/bitnami/postgresql/bin/pg_restore'
  ['cd4pe','query'].each do |db|
    # The dbname is just giving postgresql a db to connect to when running commands.  No changes are made to it
    pg_command = "#{pgrestore} --username #{db_user} --dbname postgres --clean --create --jobs=4 #{volume_dir}/pg_#{db}.dump"
    _, stderr, status = Open3.capture3("#{runtime} exec #{container} #{pg_command}")
    if !status.success?
      fail_task("Failed to restore #{db} database on target host. See bolt_debug.log for additional details.", stderr, backup_dir)
    end
  end
  # Clean up files we copied into the volume
  rm_command = "rm #{volume_dir}/pg_cd4pe.dump #{volume_dir}/pg_query.dump"
  Open3.capture2("#{runtime} exec #{container} #{rm_command}")
end

# Restores the docker volumes from the backup
# @param [String] backup_dir The full path to the directory containing the backup
# @param [String] params The parameters passed into the task
# @return [Array] warnings encountered during the restore process
#   We don't fail during this, since failing to restore volumes is not a fatal error
#   A user may be willing accept missing logs, so we just warn them.
def restore_volumes(backup_dir, params)
  runtime = params['runtime']
  image = params['image']

  # read in metadata
  metadata = JSON.parse(File.read(File.join(backup_dir, 'metadata.json')))

  # copy the files into their respective volumes
  warnings = []
  metadata['volumes'].each do |volume|
    volume_tar = File.join(backup_dir, 'volumes', "#{volume['container']}-#{volume['name']}.backup.tar")
    results = delete_all_files_from_volume(volume['name'], runtime, image)
    if !results['successful']
      warnings << "Error removing previous contents of volume '#{volume['name']}': #{results['error']}"
    end
    results = copy_file_into_volume(volume_tar, volume['name'], runtime, image)
    if !results['successful']
      warnings << "Error copying '#{File.basename(volume_tar)}' into volume '#{volume['name']}: #{results['error']}"
    end
    results = extract_volume_archive(File.basename(volume_tar), volume['name'], runtime, image)
    if !results['successful']
      warnings << "Error extracting archive '#{File.basename(volume_tar)}' in volume '#{volume['name']}: #{results['error']}"
    end
    # Delete the archive file from the volume
    results = delete_file_from_volume(File.basename(volume_tar), volume['name'], runtime, image)
    if !results['successful']
      warnings << "Unable to delete archive '#{File.basename(volume_tar)}' from volume '#{volume['name']}: #{results['error']}"
    end
  end
  warnings
end

params = JSON.parse(STDIN.read)

zipfile = File.join(params['backup_dir'], params['backup_archive'])
backup_dir = zipfile[/(.*?)\.zip/, 1]

extract_backup(zipfile)

restore_database(backup_dir, params)

warnings = restore_volumes(backup_dir, params)

# Remove working directory
FileUtils.rm_rf(backup_dir) if File.directory?(backup_dir)

output = { 
  'message' => 'Restore completed successfully',
  'warnings' => warnings,
  'error' => '',
}
puts output.to_json
