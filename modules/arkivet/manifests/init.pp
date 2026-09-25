class arkivet (
  String $hostname = $facts['networking']['fqdn'],
) {
  # The web-apps (arkivet, citat, ...) all run as this user, but it was
  # never actually declared. Fixing that.
  user { 'holger':
    ensure => present,
    home   => '/home/holger',
    shell  => '/bin/bash',
    managehome => true,
  }

  file { '/home/holger':
    ensure => directory,
    owner  => 'holger',
    group  => 'holger',
    mode   => '0755',
  }

  file { '/etc/systemd/system/arkivet.service':
    source => 'puppet:///modules/arkivet/arkivet.service',
  }~>
  exec { 'load arkivet unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  # The unit used to live in /lib/systemd/system. Remove the stale
  # copy left behind on upgraded machines so it cannot shadow or
  # confuse; /etc/systemd/system wins anyway.
  file { '/lib/systemd/system/arkivet.service':
    ensure => absent,
  }
  File['/lib/systemd/system/arkivet.service'] ~> Exec['load arkivet unit file']

  file { '/srv/arkivet-testdata':
    ensure  => directory,
    owner   => 'holger',
    group   => 'holger',
    recurse => true,
    source  => '/srv/holger-archive/seed-archive-root',
  }

  vcsrepo { '/srv/holger-archive':
    ensure     => latest,
    provider   => git,
    owner      => 'holger',
    group      => 'holger',
    # Varför? För att github kräver att man har olika deploy-keys för varje repo
    # щ（ﾟДﾟщ）
    source     => 'git@helvetesjavlaskit.github.com:holgerspexet/holger-archive.git',
    before => File['/srv/arkivet-testdata'],
  }

  # Node.js straight from the distro (LTS in Ubuntu 26.04), the old
  # nodejs module with its EOL 11.x repo is gone.
  package { 'nodejs':
    ensure => installed,
  }->
  exec { 'compile holger-archive app':
    command => 'npm ci && npm run build',
    environment => [
      "HOLGER_ARCHIVE_HOSTING=/arkivet/",
      "HOLGER_ARCHIVE_PORT=3001",
      "HOLGER_ARCHIVE_ROOT=/storage/arkivet",
      "HOLGER_ARCHIVE_CLIENT_ROOT=/srv/holger-archive/app/client/dist",
      "HOLGER_ARCHIVE_TMP_DIR=/tmp/arkivet",
    ],
    cwd     => '/srv/holger-archive',
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    user    => 'holger',
    refreshonly => true,
    subscribe   => Vcsrepo['/srv/holger-archive'],
    notify      => [Service['arkivet'],],
  }

  service { 'arkivet':
    ensure => running,
    enable => true,
    require => [
      Exec['compile holger-archive app'],
      Exec['load arkivet unit file'],
      File['/srv/arkivet-testdata'],
     ],
  }

  ::nginx::resource::location { 'arkivet':
    ensure => present,
    location => '/arkivet/',
    server => $hostname,
    ssl => true,
    ssl_only => true,
    proxy => 'http://localhost:3001',

    location_cfg_append => {
      auth_request => '/holger-auth',
      error_page => "401 = /login?back_url=https%3A%2F%2F${hostname}%2Farkivet",
      client_max_body_size => "100M",
    },
   }

  ::nginx::resource::location { 'arkivet-media-directory-listing':
    ensure => present,
    location => '/arkivet/filer/media/',
    server => $hostname,
    ssl => true,
    ssl_only => true,
    index_files => ['nogenerics.go'], # Needs to be filled with something -.-
    autoindex => 'on',

    location_cfg_append => {
      auth_request => '/holger-auth',
      error_page => "401 = /login?back_url=https%3A%2F%2F${hostname}%2Farkivet%2Ffiler%2F",
      alias => '/storage/media/',
    },
   }

  ::nginx::resource::location { 'arkivet-directory-listing':
    ensure => present,
    location => '/arkivet/filer/',
    server => $hostname,
    ssl => true,
    ssl_only => true,
    index_files => ['nogenerics.go'], # Needs to be filled with something -.-
    autoindex => 'on',

    location_cfg_append => {
      auth_request => '/holger-auth',
      error_page => "401 = /login?back_url=https%3A%2F%2F${hostname}%2Farkivet%2Ffiler%2F",
      alias => '/storage/gamla-arkivet/',
    },
   }

  # TODO: /storage used to be an NFS mount from babelfish, which is
  # gone. Hook it up to the new storage solution once decided.
  file { '/storage':
    ensure => directory,
  }

  include ::nginx
}
