# @api private
#
# Ensures that this version of CD4PE's application images are on all infra targets.
#
# Will locally cache the images to {boltproject}/downloads/ to speed up plan re-runs
#
# @param config Cd4pe::Config config object from hiera
#
# @return This plan does not return anything
plan cd4pe::install::upload_images(
  Cd4pe::Config $config,
) {
  $images_cache_dir = file::join(cd4pe::download_dir(), 'images')
  without_default_logging() || {
    run_command("mkdir -p ${images_cache_dir}", 'localhost')
  }

  $config['roles'].each |$role, $role_info| {
    $targets_by_role = $role_info['targets']
    $role_info['services'].each |$name, $service| {
      $image_name = $service['container']['image']
      $filename = "${regsubst($image_name, '\/', '_', 'G')}.tar.gz"
      $local_cached_image_tar_path = file::join($images_cache_dir, $filename)

      $remote_image_inspect_results = cd4pe::images::inspect($image_name, $targets_by_role)

      $remote_image_inspect_results.each |$target_run_result| {
        if !$target_run_result.ok {
          if !file::exists($local_cached_image_tar_path) {
            without_default_logging() || {
              if !cd4pe::images::inspect($image_name, 'localhost', { '_catch_errors' => true }).ok {
                out::message("Image '${image_name}' for role '${role}' does not exist locally, pulling latest version.")
                run_command(
                  "docker pull ${image_name}",
                  'localhost',
                )
              } else {
                out::message("Image '${image_name}' for role '${role}' exists in local cache, not updating.")
              }

              out::message("Saving '${image_name}' to '${local_cached_image_tar_path}'")
              run_command(
                "docker save ${image_name} | gzip > ${local_cached_image_tar_path}",
                'localhost',
              )
            }
          }

          without_default_logging() || {
            out::message("Image '${image_name}' for '${role}' role does not exist on '${target_run_result.target.name}', uploading.")
            upload_file($local_cached_image_tar_path, '/tmp', $targets_by_role, '_run_as' => 'root')
            run_command("docker load -i /tmp/${$filename}", $targets_by_role, '_run_as' => 'root')
          }
        }
      }
    }
  }
}
