# @summary Install CD4PE. Allows user to choose a fresh install or to migrate data from 4.x.
plan cd4pe::install() {
  without_default_logging () || {
    # We peform the Bolt version check and architecture checks first and we fail fast on them
    # because the wrong Bolt version could cause problems we don't want to have to deal with and
    # if there's something wrong with their infra config, we don't want to go and install puppet
    # on a bunch of machines if we don't need/have/want to
    $bolt_result = run_plan('cd4pe::preflight::bolt')
    out::message(cd4pe::checks::format_results('bolt: checking for supported version', $bolt_result))

    if(length($bolt_result['failed']) > 0) {
      out::message(cd4pe::checks::format_summary([$bolt_result]))
      fail_plan($bolt_result['failed'][0], 'cd4pe/error')
    }
  }

  $new = 'New install'
  $config_path = "${cd4pe::bolt_project_dir()}/data/common.yaml"
  $install_type = prompt::menu('What kind of install do you want to perform?', [$new, 'Migrate data from 4.x'])

  if file::exists($config_path) {
    $regen = 'Overwrite config'
    $use_existing = Boolean(prompt("Existing config found at ${config_path}. Would you like to use it?", 'default' => 'yes'))
    if $use_existing {
      out::message('Using existing config.')
    } else {
      out::message('Overwriting config.')

      if $install_type == $new {
        run_plan('cd4pe::install::new::bootstrap')
      } else {
        run_plan('cd4pe::install::from_4x::bootstrap')
      }
    }
  } else {
    if $install_type == $new {
      run_plan('cd4pe::install::new::bootstrap')
    } else {
      run_plan('cd4pe::install::from_4x::bootstrap')
    }
  }

  run_plan('cd4pe::install::install_app')

  if $install_type != $new {
    out::message('Migrating data from 4.x database. (NOT IMPLEMENTED YET)')
  }
}
