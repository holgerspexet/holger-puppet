class insidan::openproject (
  # nginx server_name and certificate default to the machine fqdn.
  String $hostname = $facts['networking']['fqdn'],
  # 'podman' runs OpenProject from the official containers via
  # podman-compose (the deb packages are dead for new distros).
  # 'deb' is the old packager.io install, kept for reference on the
  # original 18.04 box until it is migrated.
  Enum['podman', 'deb'] $mode = 'podman',
) {
  include ::nginx
  include ::insidan::certificates

  if $mode == 'podman' {
    package { ['podman', 'podman-compose']:
      ensure => 'installed',
    }

    file { '/opt/openproject':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { '/opt/openproject/docker-compose.yml':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/insidan/openproject/docker-compose.yml',
      require => File['/opt/openproject'],
    }

    file { '/opt/openproject/generate-env.sh':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/insidan/openproject/generate-env.sh',
      require => File['/opt/openproject'],
    }

    # Random secrets are generated once and then left alone.
    exec { 'generate openproject env':
      command => "/opt/openproject/generate-env.sh ${hostname} /opt/openproject/.env",
      creates => '/opt/openproject/.env',
      path    => ['/usr/bin', '/bin'],
      require => File['/opt/openproject/generate-env.sh'],
    }

    file { '/etc/systemd/system/openproject.service':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/insidan/openproject/openproject.service',
    }~>
    exec { 'reload openproject unit':
      refreshonly => true,
      command     => '/bin/systemctl daemon-reload',
    }

    service { 'openproject':
      ensure  => running,
      enable  => true,
      require => [
        Package['podman-compose'],
        File['/opt/openproject/docker-compose.yml'],
        Exec['generate openproject env'],
        Exec['reload openproject unit'],
      ],
      subscribe => Exec['reload openproject unit'],
    }

    file { '/opt/pg_dump_podman.sh':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/insidan/pg_dump_podman.sh',
    }

    cron { 'pg_dump openproject':
      ensure   => present,
      command  => '/opt/pg_dump_podman.sh',
      user     => root,
      minute   => 45,
      require  => [File['/opt/pg_dump_podman.sh'], File['/pg_dump']],
    }

    file { '/pg_dump':
      ensure => directory,
    }
  } else {
    # Old packager.io install. Someone MUST run `openproject configure`
    # after installing, at least until we configure it via puppet...
    exec { 'install openproject repos':
      command => 'wget -qO- https://dl.packager.io/srv/opf/openproject-ce/key | apt-key add - && wget -O /etc/apt/sources.list.d/openproject-ce.list https://dl.packager.io/srv/opf/openproject-ce/stable/10/installer/ubuntu/18.04.repo',
      creates => '/etc/apt/sources.list.d/openproject-ce.list',
      path    => ['/usr/bin', '/usr/sbin', '/bin'],
    }
    package { 'openproject':
      ensure  => installed,
      require => Exec['install openproject repos'],
    }

    package { ['postgresql', 'postgresql-contrib', 'libpq-dev', 'pgloader']:
      ensure => 'installed',
    }

    file { '/pg_dump':
      ensure  => directory,
      owner   => 'postgres',
      require => Package['postgresql'],
    }

    file { '/opt/pg_dump.sh':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/insidan/pg_dump.sh',
    }

    cron { 'pg_dump openproject':
      ensure   => present,
      command  => '/opt/pg_dump.sh',
      user     => root,
      minute   => 45,
      require  => [File['/opt/pg_dump.sh'], File['/pg_dump']],
    }
  }

  # Setup Nginx. TLS terminates here and is forwarded to the container
  # stack (web on 6000, hocuspocus websocket on 6001).
  nginx::resource::server { $hostname:
    require     => Class['::insidan::certificates'],
    server_name => [$hostname],
    proxy       => 'http://127.0.0.1:6000',

    # Encrypt everything
    ssl_redirect => true,
    ssl          => true,
    ssl_cert     => "/etc/letsencrypt/live/${hostname}/fullchain.pem",
    ssl_key      => "/etc/letsencrypt/live/${hostname}/privkey.pem",

    # Forward secret stuff
    proxy_set_header => ["Host \$host",
                         "X-Forwarded-Proto \$scheme",
                         "X-Forwarded-Host \$host",
                         "X-Forwarded-Server \$host",
                         "X-Forwarded-For \$proxy_add_x_forwarded_for",],
    ssl_protocols            => 'TLSv1.2 TLSv1.3',
    ssl_ciphers              => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256',
    ssl_prefer_server_ciphers => 'on',
  }

  # Collaborative editing websocket. Must not go through the web proxy,
  # hocuspocus speaks its own protocol.
  nginx::resource::location { 'holger-hocuspocus':
    ensure   => present,
    location => '/hocuspocus',
    server   => $hostname,
    ssl      => true,
    ssl_only => true,
    proxy    => 'http://127.0.0.1:6001',
    proxy_http_version => '1.1',
    proxy_set_header => [
      'Host $host',
      'Upgrade $http_upgrade',
      'Connection "upgrade"',
      'X-Forwarded-Proto $scheme',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
    ],
  }

  # Setup authentication endpoint
  nginx::resource::location { 'holger-auth':
    ensure   => present,
    location => '/holger-auth',
    server   => $hostname,
    ssl      => true,
    ssl_only => true,
    proxy    => "https://${hostname}/api/v3/users/me",
    location_cfg_append => {
      proxy_pass_request_body => 'off',
    },
    proxy_set_header => [
      'Host $host',
      'Content-Length ""',
      'X-Original-URI $request_uri',
    ],
  }

  # Setup another authentication endpoint
  nginx::resource::location { 'holger-auth-styrelsen':
    ensure   => present,
    location => '/holger-auth-styrelsen',
    server   => $hostname,
    ssl      => true,
    ssl_only => true,
    proxy    => "https://${hostname}/projects/styrelsen/settings",
    location_cfg_append => {
      proxy_pass_request_body => 'off',
    },
    proxy_set_header => [
      'Host $host',
      'Content-Length ""',
      'X-Original-URI $request_uri',
    ],
  }
}
