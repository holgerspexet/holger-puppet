class paragrafryttare {
  # package { ['python3-requests', 'python3-flask', 'uwsgi', 'uwsgi-plugin-python3']:
  #   ensure => installed,
  # }
  package { ['python3-flask-migrate',
             'python-flask-sqlalchemy',
             'python3-flask-restful',]:
    ensure => installed,
  }

  user { 'paragrafryttare':
    ensure      => present,
    home        => '/paragrafryttare',
    manage_home => true,
  }

  vcsrepo { '/opt/paragrafryttare':
    ensure   => latest,
    owner    => 'paragrafryttare',
    provider => git,
    source   => 'https://gitlab+deploy-token-80:4Vopcyj1e5KAVSfsWeVe@gitlab.liu.se/holgerspexet/paragrafryttare.git',
    notify   => [Service['paragrafryttare'], Exec['migrate paragrafryttare database']],
  }->
  file { '/lib/systemd/system/paragrafryttare.service':
    source => 'puppet:///modules/paragrafryttare/paragrafryttare.service',
  }~>
  exec { 'load paragrafryttare unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  exec { 'migrate paragrafryttare database':
    refreshonly => true,
    command     => '/usr/bin/flask db upgrade',
    cwd         => '/opt/paragrafryttare'
    environment => ['FLASK_APP=paragrafryttare',
                    'DATABASE_URI=/paragrafryttare/paragrafryttare.db', ],
    user        => 'paragrafryttare',
    notify      => [Service['paragrafryttare'],], 
  }

  service { 'paragrafryttare':
    ensure => running,
    enable => true,
    require => [
      File['/lib/systemd/system/paragrafryttare.service'],
     ],
  }

  ::nginx::resource::location { 'paragrafryttare':
    ensure => 'present',
    location => '/paragrafryttare/',
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    location_cfg_append => {
      include => 'uwsgi_params',
      uwsgi_pass => 'unix:/tmp/paragrafryttare.sock',
      auth_request => '/api/v3/users/me',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Fparagrafryttare%2',
    },
  }
}
