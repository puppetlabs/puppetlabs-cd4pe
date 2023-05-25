# @summary creates a shared volume for storing interservice auth tokens
class cd4pe::interservice_auth () {
  docker_volume { 'cd4pe-query-service-token':
    ensure => present,
  }
}
