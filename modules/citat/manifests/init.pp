class citat {
  file { '/lib/systemd/system/citat.service':
    source => 'puppet:///modules/citat/citat.service',
  }~>
  exec { 'load citat unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  vcsrepo { '/srv/holger-quotes':
    ensure     => latest,
    provider   => git,
    owner      => 'holger',
    group      => 'holger',
    # Varför? För att github kräver att man har olika deploy-keys för varje repo
    # щ（ﾟДﾟщ）
    # 
    source     => 'git@deploy-holger-quotes.github.com:holgerspexet/holger-quotes.git',
  }

  exec { 'compile holger-quotes app':
    command => 'bash -c "cd /srv/holger-quotes; go build -o holger-quotes"',
    cwd => '/srv/holger-quotes',
    path => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/go/bin'],
    user => 'holger',
    environment => [ 'HOME=/home/holger' ],
    refreshonly => true,
    subscribe => Vcsrepo['/srv/holger-quotes'],
    notify => [ Service['citat'], ],
  }

  service { 'citat':
    ensure => running,
    enable => true,
    require => [
      Exec['compile holger-quotes app'],
      Exec['load citat unit file'],
     ],
  }

  ::nginx::resource::location { 'citat':
    ensure => present,
    location => '/citat/',
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    proxy => 'http://localhost:3010',

    location_cfg_append => {
      auth_request => '/holger-auth',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Fcitat',
    },
   }

  include nginx
}
