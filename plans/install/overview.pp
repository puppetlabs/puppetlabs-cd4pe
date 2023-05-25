# @api private
#
# Prints summary information and next steps post-install
#
# @param config Cd4pe::Config object with all config options
#
# @return Does not return anything
plan cd4pe::install::overview(
  Cd4pe::Config $config
) {
  $browser_certs_dir = file::join(cd4pe::bolt_project_files_dir(), 'cd4pe', 'browser_certs')
  $application_url = $config['roles']['backend']['services']['pipelinesinfra']['resolvable_hostname']
  $root_login = $config['roles']['backend']['services']['pipelinesinfra']['root_username']

  $role_summary = $config['roles'].reduce('') |$memo, $role| {
    "${memo}${role[0]}:\n  ${role[1]['targets'].join(', ')}\n"
  }

  $next_steps = @("NEXTSTEPS"/L)
            
========== Next steps ================================================
1. You can now access the CD4PE application at https://${application_url}
     Root login: ${root_login}


2. To create a backup, run the cd4pe::backup plan.
======================================================================

See https://www.puppet.com/docs/continuous-delivery/5.x/cd_user_guide.html for more information.

  | NEXTSTEPS

  without_default_logging () || {
    out::message("\nCD4PE successfully installed to:")
    out::message($role_summary)
    out::message($next_steps)
  }
}
