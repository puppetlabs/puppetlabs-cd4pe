# @summary Install CD4PE
plan cd4pe::install() {
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

  run_plan('cd4pe::install::overview',
    config => $config
  )
}
