# == Class: profile_influxdb
#
# Full description of class profile_influxdb here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class profile_influxdb
{
  class { '::profile_influxdb::install': } ->
  class { '::profile_influxdb::config': } ~>
  class { '::profile_influxdb::service': } ->
  Class['::profile_influxdb']
}
