# == Class profile_influxdb::install
#
# This class is called from profile_influxdb for install.
#
class profile_influxdb::install {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
#  $_operatingsystem = downcase($::operatingsystem)

  class { 'grafana':
    cfg => {
      app_mode => 'production',
      server   => {
        http_port     => 8080,
      },
      database => {
        type     => 'sqlite3',
        host     => '127.0.0.1:3306',
        name     => 'grafana',
        user     => 'root',
        password => '',
      },
      users    => {
        allow_sign_up => false,
      },
    },
  }

  class {'influxdb':
    global_config  => $::global_config,
    manage_repos   => true,
    manage_service => true,
  }

}
