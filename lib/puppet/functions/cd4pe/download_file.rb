# frozen_string_literal: true

require 'pathname'
require 'fileutils'
require 'bolt/error'

# Downloads the given file or directory from the given set of targets and saves it to a directory
# matching the target's name under the given destination directory. Returns the result from each
# download. This does nothing if the list of targets is empty.
# 
# This function is largely a copy of:
#    https://github.com/puppetlabs/bolt/blob/8f7d5ea3ef49dadc5e166d5d802d091abc4b02bc/bolt-modules/boltlib/lib/puppet/functions/download_file.rb
# but fixes several problems we ran into:
#   1. It expected a relative path so we would need to deal with both relative and absolute paths which is a pain.
#   2. The function was destructive so if you call download_file multiple times within a plan with the same destination, files would be
#      deleted. Not overwritten, just straight up deleted.
#   3. There is no way to omit the source directory when you're copying a directory from a target so you end up with an unwanted directory.
#
#
# > **Note:** Not available in apply block
Puppet::Functions.create_function(:'cd4pe::download_file') do
  # Download a file or directory.
  # @param source The absolute path to the file or directory on the target(s).
  # @param destination The absolute path to the destination directory on the local system. 
  # @param targets A pattern identifying zero or more targets. See {get_targets} for accepted patterns.
  # @param options A hash of additional options.
  # @option options [Boolean] _catch_errors Whether to catch raised errors.
  # @option options [String] _run_as User to run as using privilege escalation.
  # @param use_absolute_destination When downloading a directory, use the absolute path specified by the
  # 'destination' param so the source directory is excluded along with the default target name directory.
  # @return A list of results, one entry per target, with the path to the downloaded file under the
  #         `path` key.
  # @example Download a file from multiple Linux targets to a destination directory
  #   download_file('/etc/ssh/ssh_config', '~/Downloads', $targets)
  dispatch :download_file do
    param 'String[1]', :source
    param 'String[1]', :destination
    param 'Boltlib::TargetSpec', :targets
    optional_param 'Hash[String[1], Any]', :options
    optional_param 'Boolean', :omit_src_dir
    return_type 'ResultSet'
  end

  def download_file(source, destination, targets, options = {}, omit_src_dir = false)
    unless Puppet[:tasks]
      raise Puppet::ParseErrorWithIssue
              .from_issue_and_stack(Bolt::PAL::Issues::PLAN_OPERATION_NOT_SUPPORTED_WHEN_COMPILING, action: 'download_file')
    end

    options = options.select { |opt| opt.start_with?('_') }.transform_keys { |k| k.sub(/^_/, '').to_sym }
    executor = Puppet.lookup(:bolt_executor)
    inventory = Puppet.lookup(:bolt_inventory)

    if (destination = destination.strip).empty?
      raise Bolt::ValidationError, "Destination cannot be an empty string"
    end

    unless (destination = Pathname.new(destination)).absolute?
      raise Bolt::ValidationError, "Destination must be an absolute path, received relative path #{destination}"
    end

    # Prevent path traversal so downloads can't be saved outside of the project downloads directory
    if (destination.each_filename.to_a & %w[. ..]).any?
      raise Bolt::ValidationError, "Destination must not include path traversal, received #{destination}"
    end

    # Ensure that that given targets are all Target instances
    targets = inventory.get_targets(targets)
    if targets.empty?
      call_function('debug', "Simulating file download of '#{source}' - no targets given - no action taken")
      Bolt::ResultSet.new([])
    else
      file_line = Puppet::Pops::PuppetStack.top_of_stack
      download_results = if executor.in_parallel?
            executor.run_in_thread do
              executor.download_file(targets, source, destination, options, file_line)
            end
          else
            executor.download_file(targets, source, destination, options, file_line)
          end

      if !download_results.ok && !options[:catch_errors]
        raise Bolt::RunFailure.new(download_results, 'download_file', source)
      end

      if omit_src_dir
        download_results.each do |result|
          target_dest_dir = result.value["path"]
          target_dir = File.dirname(target_dest_dir)
          parent_dir = File.dirname(target_dir)
          files_to_move = Dir.children(target_dest_dir).map do |f|
            File.join(target_dest_dir, f)
          end
          FileUtils.mv(files_to_move, parent_dir)
          FileUtils.remove_dir(target_dir)
        end
      end
      download_results
    end
  end
end
