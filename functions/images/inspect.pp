# runs an runtime appropriate image inspect command on the
# specified targets.

# @param image_name The image name to inspect
# @param target targets to run the image inspect command on
# @param opts Optional options if you need to override the defaults
#   passed to run_command, for eample in when running against localhost
#
# @return ResultSet results per target, stdout will contain
#   a json hash if the image exists, otherwise non-zero exit
#   code.
function cd4pe::images::inspect(
  String[1] $image_name,
  TargetSpec $targets,
  Optional[Hash] $opts = undef,
) >> ResultSet {
  $cmd_opts = $opts ? {
    undef   => { '_run_as' => 'root', '_catch_errors' => true, },
    default => $opts,
  }

  without_default_logging() || {
    $image_inspect_results = run_command(
      "docker image inspect ${image_name} --format '{{ json . }}' 2> /dev/null",
      $targets,
      $cmd_opts,
    )
  }
}
