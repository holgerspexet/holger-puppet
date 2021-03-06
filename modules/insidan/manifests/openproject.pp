class insidan::openproject {
  include nginx
  include insidan::certificates
  # This is horrible. Please fix.
  exec { 'install openproject repos':
    command => 'bash -e wget -qO- https://dl.packager.io/srv/opf/openproject-ce/key | apt-key add -; sudo wget -O /etc/apt/sources.list.d/openproject-ce.list
    https://dl.packager.io/srv/opf/openproject-ce/stable/10/installer/ubuntu/18.04.repo',
    creates => '/etc/apt/sources.list.d/openproject-ce.list',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
  }~>
  package { 'openproject' :
    ensure => installed,
  # Here, someone MUST run `openproject configure`. At least until we
  # configure it via puppet...
  }


  package { [ 'postgresql', 'postgresql-contrib', 'libpq-dev', 'pgloader' ]:
    ensure => installed,
  }

  file { '/pg_dump':
    ensure => directory,
    owner => 'postgres',
    require => Package['postgresql'],
  }

  file { '/opt/pg_dump.sh':
    ensure => file,
    mode   => '755',
    source => 'puppet:///modules/insidan/pg_dump.sh',
  }

  cron { 'pg_dump openproject':
    ensure => present,
    command => '/opt/pg_dump.sh',
    user => root,
    minute => 45,
    require => [ File['/opt/pg_dump.sh'], File['/pg_dump'] ]
  }



  # Setup Nginx
  nginx::resource::server { 'insidan.holgerspexet.se':
    require => [ Class['::insidan::certificates'], ],
    server_name => ['insidan.holgerspexet.se'],
    proxy => 'http://localhost:6000',

    # Encrypt everything
    ssl_redirect => true,
    ssl   => true,
    ssl_cert  => '/etc/letsencrypt/live/insidan.holgerspexet.se/fullchain.pem',
    ssl_key  => '/etc/letsencrypt/live/insidan.holgerspexet.se/privkey.pem',

    # Forward secret stuff
    proxy_set_header => [ "X-Forwarded-Proto \$scheme",
                          "X-Forwarded-Host \$host",
                          "X-Forwarded-Server \$host",
                          "X-Forwarded-For \$proxy_add_x_forwarded_for", ],
    # Set the paranoia level to 'high'.
    ssl_protocols => 'TLSv1.2',
    ssl_ciphers =>  'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256',
    ssl_prefer_server_ciphers => 'on',
  }

  file { '/opt/openproject/public/assets/logo_openproject_white_big-2c6d79fa03613154cf6bd67c622dbae5b93ed3199e0e7332d96b6f8ec21f85a1.png':
    ensure => file,
    source => 'puppet:///modules/insidan/holgerlogga.png'
  }

  file { '/srv/test.png':
    ensure => file,
    source => 'puppet:///modules/insidan/holgerlogga.png'
  }

  # Setup authentication endpoint
  nginx::resource::location { 'holger-auth':
    ensure   => present,
    location => '/holger-auth',
    server   => 'insidan.holgerspexet.se',
    ssl      => true,
    ssl_only => true,
    proxy    => 'https://insidan.holgerspexet.se/api/v3/users/me',
    location_cfg_append => {
      proxy_pass_request_body => 'off',
    },
    proxy_set_header => [
      'Content-Length ""',
      'X-Original-URI \$request_uri',
    ],
  }
  # Setup another authentication endpoint
  nginx::resource::location { 'holger-auth-styrelsen':
    ensure   => present,
    location => '/holger-auth-styrelsen',
    server   => 'insidan.holgerspexet.se',
    ssl      => true,
    ssl_only => true,
    proxy    => 'https://insidan.holgerspexet.se/projects/styrelsen/settings',
    location_cfg_append => {
      proxy_pass_request_body => 'off',
    },
    proxy_set_header => [
      'Content-Length ""',
      'X-Original-URI \$request_uri',
    ],
  }
}
