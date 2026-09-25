class grunkor (
  String $hostname = $facts['networking']['fqdn'],
) {
  package { ['python3-requests', 'python3-flask', 'uwsgi', 'uwsgi-plugin-python3']:
    ensure => installed,
  }

  user { 'grunkor':
    ensure => present,
    shell  => '/bin/bash',
    managehome => true,
  }

  vcsrepo { '/opt/grunkor':
    ensure   => latest,
    owner    => 'grunkor',
    provider => git,
    source   => 'git@github.com:holgerspexet/holger-grunkor.git',
    notify   => Service['grunkor'],
  }->
  file { '/etc/systemd/system/grunkor.service':
    source => 'puppet:///modules/grunkor/grunkor.service',
  }~>
  exec { 'load grunkor unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  # The unit used to live in /lib/systemd/system. Remove the stale
  # copy left behind on upgraded machines.
  file { '/lib/systemd/system/grunkor.service':
    ensure => absent,
  }
  File['/lib/systemd/system/grunkor.service'] ~> Exec['load grunkor unit file']

  service { 'grunkor':
    ensure => running,
    enable => true,
    require => [
      File['/etc/systemd/system/grunkor.service'],
     ],
  }

  ::nginx::resource::location { 'grunkor':
    ensure => 'present',
    location => '/grunkor/',
    server => $hostname,
    ssl => true,
    ssl_only => true,
    location_cfg_append => {
      include => 'uwsgi_params',
      uwsgi_pass => 'unix:/tmp/grunkor.sock',
      auth_request => '/holger-auth',
      error_page => "401 = /login?back_url=https%3A%2F%2F${hostname}%2Fgrunkor%2F",
    },
  }
}
