# == Class profile_influxdb::install
#
# This class is called from profile_influxdb for install.
#
class profile_influxdb::install {
  # prevent direct use of subclass
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $_operatingsystem = downcase($::operatingsystem)

#  apt::source { 'packagecloud.io':
#    location    => 'https://packagecloud.io/grafana/testing/debian/',
#    release     => 'jessie',
#    repos       => 'main',
#    key         => {
#      'id'     => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
#      'server' => 'pgp.mit.edu',
#    },
#    include_src => false,
#    notify      => Exec[ '/usr/bin/apt-get update' ],
#  }

#  apt::source { 'repos.influxdata.com':
#    location    => "https://repos.influxdata.com/${_operatingsystem}",
#    release     => $::lsbdistcodename,
#    repos       => 'stable',
#    key         => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
#    key_source  => 'https://repos.influxdata.com/influxdb.key',
#    include_src => false,
#    notify      => Exec[ '/usr/bin/apt-get update' ],
#  }

#  exec { '/usr/bin/apt-get update':
#    refreshonly => true,
#    before      => [ Class['influxdb::server'], Package['grafana'] ],
#  }

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

#  class {'influxdb::server':
#    manage_repos => false,
#    require      => Apt::Source['repos.influxdata.com'],
#  }

#  package {'grafana':
#    ensure          => installed,
#    install_options => ['--allow-unauthenticated', '-f'],
#    require         => Apt::Source['packagecloud.io'],
#  }

}
