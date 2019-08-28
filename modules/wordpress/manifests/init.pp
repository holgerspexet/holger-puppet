class wordpress {
  package { [ 'php', 'libapache2-mod-php', 'php-mysql', 'mysql-server' ]:
    ensure => latest,
  }

  file { '/srv/holgerspexet-wordpress':
    ensure => directory,
  }

  file { '/mysql_dump':
    ensure => directory,
  }

  file { '/opt/mysql_dump.sh':
    ensure => file,
    mode   => '755',
    source => 'puppet:///modules/wordpress/opt/mysql_dump.sh',
  }

  cron { 'mysqldump':
    ensure => present,
    command => '/opt/mysql_dump.sh',
    user => root,
    minute => 35,
    require => [ File['/mysql_dump'], File['/opt/mysql_dump.sh']],
  }


  include wordpress::certificates;

  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
    require => [ Class['::wordpress::certificates'], ],
  }

  include apache::mod::rewrite
  include apache::mod::php

  apache::vhost { 'holgerspexet-public.lysator.liu.se ssl':
    servername => 'holgerspexet-public.lysator.liu.se',
    port    => '443',
    docroot => '/srv/holgerspexet-wordpress',
    ssl   => true,
    ssl_cert  => '/etc/letsencrypt/live/holgerspexet.se/fullchain.pem',
    ssl_key  => '/etc/letsencrypt/live/holgerspexet.se/privkey.pem',
  }

  apache::vhost { 'holgerspexet-public.lysator.liu.se non-ssl':
    servername => 'holgerspexet-public.lysator.liu.se',
    port => '80',
    docroot => '/var/www/redirect',
    redirect_status => 'permanent',
    redirect_dest => 'https://holgerspexet-public.lysator.liu.se',
  }

  apache::vhost { 'holgerspexet.se ssl':
    servername => 'holgerspexet.se',
    port    => '443',
    docroot => '/srv/holgerspexet-wordpress',
    ssl   => true,
    ssl_cert  => '/etc/letsencrypt/live/holgerspexet.se/fullchain.pem',
    ssl_key  => '/etc/letsencrypt/live/holgerspexet.se/privkey.pem',
  }

  apache::vhost { 'holgerspexet.se non-ssl':
    servername => 'holgerspexet.se',
    port => '80',
    docroot => '/var/www/redirect',
    redirect_status => 'permanent',
    redirect_dest => 'https://holgerspexet.se',
  }


  apache::vhost { 'dev.holgerspexet.se ssl':
    servername => 'dev.holgerspexet.se',
    port    => '443',
    docroot => '/srv/holgerspexet-wordpress',
    ssl   => true,
    ssl_cert  => '/etc/letsencrypt/live/holgerspexet.se/fullchain.pem',
    ssl_key  => '/etc/letsencrypt/live/holgerspexet.se/privkey.pem',
  }

  apache::vhost { 'dev.holgerspexet.se non-ssl':
    servername => 'dev.holgerspexet.se',
    port => '80',
    docroot => '/var/www/redirect',
    redirect_status => 'permanent',
    redirect_dest => 'https://dev.holgerspexet.se',
  }
}

