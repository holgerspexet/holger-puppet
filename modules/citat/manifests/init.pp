class citat {
  file { '/lib/systemd/system/citat.service':
    source => 'puppet:///modules/citat/citat.service',
  }~>
  exec { 'load citat unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  file { '/srv/holger-quotes':
    ensure => directory,
  }
  
  file { '/srv/holger-quotes/is-new-version-available.sh':
    source => 'puppet:///modules/citat/is-new-version-available.sh',
    mode => '+x'
    require => File['/srv/holger-quotes'],
  }

  exec { 'download binary for holger-quotes':
    command => 'wget https://github.com/holgerspexet/holger-quotes/releases/latest/download/holger-quotes -O /srv/holger-quotes/holger-quotes',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    require => [
      File['/srv/holger-quotes'],
      File['/srv/holger-quotes/is-new-version-available.sh']
    ],
    onlyif => '/srv/holger-quotes/is-new-version-available.sh /srv/holger-quotes/holger-quotes',
  }~>
  exec { 'enable execution of holger-quotes':
    command => 'chmod +x /srv/holger-quotes/holger-quotes',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    refreshonly => true,
  }

  service { 'citat':
    ensure => running,
    enable => true,
    require => [
      Exec['enable execution of holger-quotes'],
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
