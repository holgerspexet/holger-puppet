class wordpress {
  package { [ 'php', 'libapache2-mod-php', 'php-mysql', 'mysql-server' ]:
    ensure => latest,
  }

  file { '/srv/holgerspexet-wordpress':
    ensure => directory,
  }

  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  include apache::mod::rewrite
  include apache::mod::php

  apache::vhost { 'holgerspexet-public.lysator.liu.se':
    port    => '8080',
    docroot => '/srv/holgerspexet-wordpress',
  }

}
