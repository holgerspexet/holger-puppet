class citat (
  String $hostname = $facts['networking']['fqdn'],
) {
  # User[holger] is declared in arkivet, which is always a companion
  # of this class on every node. Require it here instead of
  # redeclaring (which puppet refuses).

  # The quotes database lives under /storage which used to be an NFS
  # mount from Lysator (declared in arkivet); make sure the citat
  # directory exists locally too.
  file { '/storage/citat':
    ensure => directory,
    owner  => 'holger',
    group  => 'holger',
    mode   => '0755',
    require => [User['holger'], File['/storage']],
  }

  file { '/etc/systemd/system/citat.service':
    source => 'puppet:///modules/citat/citat.service',
  }~>
  exec { 'load citat unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  # The unit used to live in /lib/systemd/system. Remove the stale
  # copy left behind on upgraded machines.
  file { '/lib/systemd/system/citat.service':
    ensure => absent,
  }
  File['/lib/systemd/system/citat.service'] ~> Exec['load citat unit file']

  file { '/srv/holger-quotes':
    ensure => directory,
  }

  file { '/srv/holger-quotes/is-new-version-available.sh':
    source => 'puppet:///modules/citat/is-new-version-available.sh',
    mode => '0755',
    require => File['/srv/holger-quotes'],
  }

  exec { 'download binary for holger-quotes':
    command => 'wget https://github.com/holgerspexet/holger-quotes/releases/latest/download/holger-quotes -O /srv/holger-quotes/holger-quotes-new',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    require => [
      File['/srv/holger-quotes'],
      File['/srv/holger-quotes/is-new-version-available.sh']
    ],
    onlyif => '/srv/holger-quotes/is-new-version-available.sh /srv/holger-quotes/holger-quotes',
  } ~>
  exec { 'enable execution of holger-quotes-new':
    command => 'chmod +x /srv/holger-quotes/holger-quotes-new',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    refreshonly => true,
  } ~>
  exec { 'update binary':
    command => 'mv /srv/holger-quotes/holger-quotes-new /srv/holger-quotes/holger-quotes',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    refreshonly => true,
    notify  => Service['citat'],
  }

  service { 'citat':
    ensure => running,
    enable => true,
    require => [
      Exec['update binary'],
      Exec['load citat unit file'],
      User['holger'],
     ],
  }

  ::nginx::resource::location { 'citat':
    ensure => present,
    location => '/citat/',
    server => $hostname,
    ssl => true,
    ssl_only => true,
    proxy => 'http://localhost:3010',

    location_cfg_append => {
      auth_request => '/holger-auth',
      error_page => "401 = /login?back_url=https%3A%2F%2F${hostname}%2Fcitat",
    },
   }

  include ::nginx
}
