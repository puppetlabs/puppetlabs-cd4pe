# Create a logrotate config for a given set of files
# This type attempts to make some sane assumptions that suit our application.
# For instance, we only keep 1 compressed log file from the previous rotation.
# We explicitly switch to root (logrotate runs as root by default anyways).
#
# @param [String[1]] path A path to files that should be rotated. Accepts file globs.
# @param [Integer[1, default]] size_mb
#   Total logs stored will be up to twice the amount specified in MB
#   here since we keep the last rotated file.
# @param [String[1]] post_rotate_cmd Command to run after rotating log files
# @param [Integer[0, default]] keep_files How many rotated log files to keep
#
# @example Rotate logs in /var/log/puppet/*.log
# cd4pe::logrotate_config('/var/log/puppet/*.log', '100M', 'echo "Reload the service"', 3)
define cd4pe::logrotate_config (
  String[1]  $path,
  Integer[1]  $size_mb,
  String[1]  $post_rotate_cmd,
  Integer[0] $keep_files,
) {
  file { "/etc/logrotate.d/cd4pe-${name}":
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    show_diff => false,
    content   => epp('cd4pe/logrotate.epp',
      {
        'path'            => $path,
        'size_mb'         => $size_mb,
        'post_rotate_cmd' => $post_rotate_cmd,
        'keep_files'      => $keep_files
    }),
    require   => Class['Cd4pe::Log_rotation'],
  }
}
