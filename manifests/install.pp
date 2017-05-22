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
    install_method => 'package',
    package_source => 'https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.2.0_amd64.deb',
    cfg            => {
      app_mode => 'production',
      server   => {
        http_port     => 3000,
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


  exec {'wait for grafana':
    require => Class['grafana'],
    command => '/usr/bin/wget --spider --tries 10 --retry-connrefused http://localhost:3000',
  }

  grafana_datasource { 'influxdb':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    database         => 'telegraf',
    access_mode      => 'proxy',
    is_default       => true,
    require          => [Class['influxdb'], Exec['wait for grafana']],
  }
  grafana_datasource { 'internal_influxdb':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    type             => 'influxdb',
    url              => 'http://localhost:8086',
    database         => '_internal',
    access_mode      => 'proxy',
    require          => [Class['influxdb'], Exec['wait for grafana']],
  }

  grafana_dashboard { 'Telegraf Windows Instances':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/windows-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['influxdb'],],
  }
  grafana_dashboard { 'HAproxy metrics':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/haproxy-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['influxdb'],],
  }
  grafana_dashboard { 'Telegraf system overview':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/telegraf-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['influxdb'],],
  }
  grafana_dashboard { 'InfluxDB Metrics':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/influxdb-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['internal_influxdb'],],
  }
  grafana_dashboard { 'Apache Overview':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/apache-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['internal_influxdb'],],
  }
  grafana_dashboard { 'MySQL Metrics':
    grafana_url      => 'http://localhost:3000',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    content          => template('profile_influxdb/mysql-dash.json.erb'),
    require          => [ Class['influxdb'], Grafana_datasource['internal_influxdb'],],
  }

}
