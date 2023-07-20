# @api private
plan cd4pe::install::update_root_credentials(Cd4pe::Config $config) {
  $username = $config['roles']['backend']['services']['pipelinesinfra']['root_username']
  $password = $config['roles']['backend']['services']['pipelinesinfra']['root_password']
  $image = $config['roles']['backend']['services']['pipelinesinfra']['container']['image']
  $log_volume_name = $config['roles']['backend']['services']['pipelinesinfra']['container']['log_volume_name']
  $env = {
    'CD4PE_ROOT_EMAIL'    => $username.unwrap,
    'CD4PE_ROOT_PASSWORD' => $password.unwrap,
  }
  if ($config['runtime'] == 'docker') {
    # TODO: We shouldn't hardcode any paths here. It seems like we'll need to push more of this into the container config.
    $update_creds_cmd = @("CMD"/L)
      docker run \
      --rm \
      --net cd4pe \
      --env-file /etc/puppetlabs/cd4pe/env \
      --env-file /etc/puppetlabs/cd4pe/secret_key \
      --env CD4PE_ROOT_EMAIL \
      --env CD4PE_ROOT_PASSWORD \
      --volume ${log_volume_name}:/app/logs \
      --volume /etc/puppetlabs/cd4pe/pfi-config.json:/etc/cd4pe/pfi-config.json \
      --volume  /etc/puppetlabs/cd4pe/log4j2.properties:/opt/pfi/log4j2.properties \
      ${image} \
      com.distelli.accounts.UpdateRootCredentials
      | - CMD
    run_command($update_creds_cmd, $config['roles']['backend']['targets'][0], '_run_as' => 'root', '_env_vars' => $env)
  } else {
    fail_plan("${config['runtime']} is not supported. Please update the configuration to 'docker'", 'cd4pe/error')
  }
}
