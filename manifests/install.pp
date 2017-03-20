# == Class profile_influxdb::install
#
# This class is called from profile_influxdb for install.
#
class profile_influxdb::install {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  class {'influxdb':
    manage_repos   => true,
    manage_service => true,
  }

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

  grafana_datasource { 'telegraf':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    database         => 'telegraf',
    user             => 'admin',
    password         => 'admin',
    access_mode      => 'proxy',
    is_default       => true,
    require          => Class['influxdb'],
  }
  grafana_datasource { 'DS_INTERNAL_INFLUXDB':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    database         => '_internal',
    user             => 'admin',
    password         => 'admin',
    access_mode      => 'proxy',
    is_default       => true,
    require          => Class['influxdb'],
  }
  grafana_dashboard { 'telegraf_dashboard':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/telegraf-dash.json.erb'),
    require          => Class['influxdb'],
  }
  grafana_dashboard { 'influxdb_dashboard':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/influxdb-dash.json.erb'),
    require          => Class['influxdb'],
  }

}
