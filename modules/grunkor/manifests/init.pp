class grunkor {
  package { ['python3-requests', 'python3-flask', 'uwsgi', 'uwsgi-plugin-python3']:
    ensure => installed,
  }

  user { 'grunkor':
    ensure => present,
  }

  vcsrepo { '/opt/grunkor':
    ensure   => latest,
    owner    => 'grunkor',
    provider => git,
    source   => 'git@github.com:holgerspexet/holger-grunkor.git',
  }->
  file { '/lib/systemd/system/grunkor.service':
    source => 'puppet:///modules/grunkor/grunkor.service',
  }~>
  exec { 'load grunkor unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  service { 'grunkor':
    ensure => running,
    enable => true,
    require => [
      File['/lib/systemd/system/grunkor.service'],
     ],
  }

  ::nginx::resource::location { 'grunkor':
    ensure => 'present',
    location => '/grunkor/',
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    location_cfg_append => {
      include => 'uwsgi_params',
      uwsgi_pass => 'unix:/tmp/grunkor.sock',
      auth_request => '/api/v3/users/me',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Fgrunkor%2',
    },
  }
}
