class arkivet {
  user { 'arkivet':
    ensure => present,
    home => '/home/arkivet',
  }
  file { '/home/arkivet':
    ensure => directory,
    owner => 'arkivet',
  }

  file { '/lib/systemd/system/arkivet.service':
    source => 'puppet:///modules/arkivet/arkivet.service',
  }~>
  exec { 'load arkivet unit file':
    refreshonly => true,
    command => '/bin/systemctl daemon-reload',
  }

  file { '/srv/arkivet-testdata':
    ensure  => directory,
    owner   => 'arkivet',
    group   => 'arkivet',
    recurse => true,
    source  => '/srv/holger-archive/seed-archive-root',
  }

  vcsrepo { '/srv/holger-archive':
    ensure     => latest,
    provider   => git,
    owner      => 'arkivet',
    group      => 'arkivet',
    # Varför? För att github kräver att man har olika deploy-keys för varje repo
    # щ（ﾟДﾟщ）
    source     => 'git@helvetesjavlaskit.github.com:holgerspexet/holger-archive.git',
    notify => Exec['compile holger-archive app'],
    before => File['/srv/arkivet-testdata'],
  }

  class { 'nodejs':
    manage_package_repo       => true,
    repo_url_suffix           => '11.x',
    nodejs_package_ensure     => 'latest',
#    npm_package_ensure        => 'latest',
  }->
  exec { 'compile holger-archive app':
    command => 'bash -c "cd /srv/holger-archive; npm ci && npm run build"',
    environment => [
      "HOLGER_ARCHIVE_HOSTING=/arkivet/",
      "HOLGER_ARCHIVE_PORT=3001",
      "HOLGER_ARCHIVE_ROOT=/srv/arkivet-testdata",
      "HOLGER_ARCHIVE_CLIENT_ROOT=/srv/holger-archive/app/client/dist",
      "HOLGER_ARCHIVE_TMP_DIR=/tmp/arkivet",
    ],
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    user => 'arkivet',
    creates => '/srv/holger-archive/app/server/dist',
    require => File['/home/arkivet'],
    refreshonly => true,
    notify => [ Service['arkivet'], ],
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
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    proxy => 'http://localhost:3001',

    location_cfg_append => {
      auth_request => '/api/v3/users/me',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Farkivet',
    },
   }

  ::nginx::resource::location { 'arkivet-media-directory-listing':
    ensure => present,
    location => '/arkivet/filer/media/',
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    index_files => ['nogenerics.go'], # Needs to be filled with something -.-
    autoindex => 'on',

    location_cfg_append => {
      auth_request => '/api/v3/users/me',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Farkivet%2Ffiler%2F',
      alias => '/storage/media/',
    },
   }

  ::nginx::resource::location { 'arkivet-directory-listing':
    ensure => present,
    location => '/arkivet/filer/',
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    index_files => ['nogenerics.go'], # Needs to be filled with something -.-
    autoindex => 'on',

    location_cfg_append => {
      auth_request => '/api/v3/users/me',
      error_page => '401 = /login?back_url=https%3A%2F%2Finsidan.holgerspexet.se%2Farkivet%2Ffiler%2F',
      alias => '/storage/gamla-arkivet/',
    },
   }

   file { '/storage':
     ensure => directory,
   }
   ~> file_line { 'fstab /storage':
     path => '/etc/fstab',
     line => '130.236.254.98:/storage/inhysningar/holger /storage nfs defaults,noatime 0 0',
   }


  include nginx
}
