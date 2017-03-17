# == Class profile_influxdb::config
#
# This class is called from profile_influxdb for service config.
#
class profile_influxdb::config {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

}
