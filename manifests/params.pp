# == Class profile_influxdb::params
#
# This class is meant to be called from profile_influxdb.
# It sets variables according to platform.
#
class profile_influxdb::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'profile_influxdb'
      $service_name = 'profile_influxdb'
    }
    'RedHat', 'Amazon': {
      $package_name = 'profile_influxdb'
      $service_name = 'profile_influxdb'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
