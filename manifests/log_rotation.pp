# Profile to manage log rotation tool
class cd4pe::log_rotation () {
  package { 'logrotate':
    ensure => present,
  }
}
