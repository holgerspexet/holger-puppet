class paragrafryttare {
  package { ['python3-flask-migrate',
             'python-flask-sqlalchemy',
             'python3-flask-restful',
             'python3-pip',]:
    ensure => installed,
  }

  user { 'paragrafryttare':
    ensure     => present,
    home       => '/paragrafryttare',
    managehome => true,
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

  exec { 'install python deps':
    refreshonly => true,
    cwd         => '/opt/paragrafryttare',
    command     => '/usr/bin/pip3 install --ignore-installed --install-option="--prefix=/paragrafryttare/env" -r requirements.txt',
    user        => 'paragrafryttare',
    subscribe   => Vcsrepo['/opt/paragrafryttare'],
    notify      => Service['paragrafryttare'],
  }
  -> exec { 'migrate paragrafryttare database':
    refreshonly => true,
    command     => '/paragrafryttare/env/bin/flask db upgrade',
    cwd         => '/opt/paragrafryttare',
    environment => [
      'FLASK_APP=paragrafryttare',
      'DATABASE_URI=sqlite:////paragrafryttare/paragrafryttare.db',
      'PYTHONPATH=/opt/paragrafryttare/:/paragrafryttare/env/lib/python3.6/site-packages',
    ],
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
      auth_request => '/holger-auth',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Fparagrafryttare%2',
    },
  }
}
