class holger::byggerom {
  include nginx
  # Setup Nginx
  nginx::resource::server { 'holgerspexet.se':
    server_name => ['holgerspexet.se', 'www.holgerspexet.se', 'holgerspexet.lysator.liu.se'],
    www_root => '/srv/byggerom/',
  }

  file { '/srv/byggerom':
    ensure => directory,
    recurse => true,
    mode => '0744',
    source => 'puppet:///modules/holger/byggerom/',
  }
}
