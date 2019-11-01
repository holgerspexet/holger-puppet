class citat {
  user { 'citat':
    ensure => present,
    home => '/home/citat',
  }
  file { '/home/citat':
    ensure => directory,
    owner => 'citat',
  }

  file { '/lib/systemd/system/citat.service':
    source => 'puppet:///modules/citat/citat.service',
  }~>
  exec { 'load citat unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  file { '/srv/holger-quotes/test.sql':
    owner   => 'citat',
    group   => 'citat',
  }

  vcsrepo { '/srv/holger-quotes':
    ensure     => latest,
    provider   => git,
    owner      => 'citat',
    group      => 'citat',
    # Varför? För att github kräver att man har olika deploy-keys för varje repo
    # щ（ﾟДﾟщ）
    # 
    # Byt deploy key
    source     => 'git@deploy-holger-quotes.github.com:holgerspexet/holger-quotes.git',
    before => File['/srv/holger-quotes/test.sql'],
  }

  exec { 'compile holger-quotes app':
    command => 'bash -c "cd /srv/holger-quotes; go build -o holger-quotes"',
    cwd => '/srv/holger-quotes',
    path => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/go/bin'],
    user => 'citat',
    environment => [ 'HOME=/home/citat' ],
    require => File['/home/citat'],
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
      File['/srv/holger-quotes/test.sql'],
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
