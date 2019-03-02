class arkivet {
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
    owner => 'root',
  }

#  ~> exec { 'install node dependencies':
#    command => 'bash -e "cd /srv/holger-archive; npm install"',
#    path => ['/usr/bin', '/usr/sbin', '/bin'],
#    creates => '/srv/holger-archive/app/server/dist',
#  }

  include nginx
}
