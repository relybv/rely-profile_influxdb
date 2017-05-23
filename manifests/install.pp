# == Class profile_influxdb::install
#
# This class is called from profile_influxdb for install.
#
class profile_influxdb::install {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $global_config = {
    'bind-address'       => ':8088',
    'reporting-disabled' => false,
  }

  $meta_config = {
    'dir'                  => '/var/lib/influxdb/meta',
    'retention-autocreate' => true,
    'logging-enabled'      => false,
  }

  $data_config = {
    'dir'                                => '/var/lib/influxdb/data',
    'wal-dir'                            => '/var/lib/influxdb/wal',
    'trace-logging-enabled'              => false,
    'query-log-enabled'                  => false,
    'cache-max-memory-size'              => 1048576000,
    'cache-snapshot-memory-size'         => 26214400,
    'cache-snapshot-write-cold-duration' => '10m',
    'compact-full-write-cold-duration'   => '4h',
    'max-series-per-database'            => 1000000,
    'max-values-per-tag'                 => 100000,
  }

  $http_config = {
    'enabled'              => true,
    'bind-address'         => ':8086',
    'auth-enabled'         => false,
    'realm'                => 'InfluxDB',
    'log-enabled'          => false,
    'write-tracing'        => false,
    'pprof-enabled'        => true,
    'https-enabled'        => false,
    'https-certificate'    => '/etc/ssl/influxdb.pem',
    'https-private-key'    => '',
    'shared-sercret'       => '',
    'max-row-limit'        => 10000,
    'max-connection-limit' => 0,
    'unix-socket-enabled'  => false,
    'bind-socket'          => '/var/run/influxdb.sock',
  }

  class {'influxdb':
    manage_repos   => true,
    manage_service => true,
    global_config  => $global_config,
    meta_config    => $meta_config,
    data_config    => $data_config,
    http_config    => $http_config,
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
