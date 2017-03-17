# == Class profile_influxdb::service
#
# This class is meant to be called from profile_influxdb.
# It ensure the service is running.
#
class profile_influxdb::service {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

#  service { 'grafana':
#    ensure => running,
#    enable => true,
#  }

}
