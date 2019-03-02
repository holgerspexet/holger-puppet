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

  class { 'nodejs':
    manage_package_repo       => true,
    repo_url_suffix           => '11.x',
    nodejs_package_ensure     => 'latest',
#    npm_package_ensure        => 'latest',
  }
  -> vcsrepo { '/opt/holger-archive-git':
    ensure     => latest,
    provider   => git,
    # Varför? För att github kräver att man har olika deploy-keys för varje repo
    # щ（ﾟДﾟщ）
    source     => 'git@helvetesjavlaskit.github.com:holgerspexet/holger-archive.git',
  }
  ~> file { '/srv/holger-archive':
    source => '/opt/holger-archive-git',
    recurse => true,
    owner => 'arkivet',
  }
  ~> exec { 'compile holger-archive app':
    command => 'bash -c "cd /srv/holger-archive; npm install && npm run build"',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    user => 'arkivet',
    creates => '/srv/holger-archive/app/server/dist',
    require => File['/home/arkivet'],
    refreshonly => true,
  }

  service { 'arkivet':
    ensure => running,
    enable => true,
    require => [
      Exec['compile holger-archive app'],
      Exec['load arkivet unit file'],
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


  include nginx
}
