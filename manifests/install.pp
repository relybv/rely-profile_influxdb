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
    version        => '1.2.1',
  }

  class { 'grafana':
    install_method => 'package',
    package_source => 'https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.1.2-1486989747_amd64.deb',
    cfg            => {
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

  grafana_datasource { 'influxdb':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    database         => 'telegraf',
    access_mode      => 'proxy',
    is_default       => true,
    require          => Class['influxdb'],
  }
  grafana_datasource { 'internal_influxdb':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    database         => '_internal',
    access_mode      => 'proxy',
    require          => Class['influxdb'],
  }
  grafana_dashboard { 'telegraf_dashboard':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/telegraf-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['influxdb'],],
  }
  grafana_dashboard { 'InfluxDB Metrics':
    grafana_url      => 'http://localhost:8080',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/influxdb-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['internal_influxdb'],],
  }

}
