# @summary Upgrade existing CD4PE instance
plan cd4pe::upgrade() {
  $config = cd4pe::config()

  run_plan('cd4pe::preflight',
    config => $config,
  )

  run_plan('cd4pe::install::runtime',
    config => $config,
  )

  run_plan('cd4pe::install::upload_images',
    config => $config,
  )

  run_plan('cd4pe::install::roles',
    config => $config,
  )

  run_plan('cd4pe::install::wait_for_services',
    config => $config,
  )

  run_plan('cd4pe::upgrade::cleanup',
    config => $config,
  )
}
