class wordpress {
  package { [ 'php', 'libapache2-mod-php', 'php-mysql', 'mysql-server' ]:
    ensure => latest,
  }

  file { '/srv/holgerspexet-wordpress':
    ensure => directory,
  }

  class { 'apache':
    default_vhost => false,
  }

  apache::vhost { 'holgerspexet-public.lysator.liu.se':
    port    => '8080',
    docroot => '/srv/holgerspexet-wordpress',
  }

}
