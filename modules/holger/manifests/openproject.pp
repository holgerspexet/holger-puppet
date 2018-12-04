class holger::openproject {
  include nginx
  include holger::certificates
  # This is horrible. Please fix.
  exec { 'install openproject repos':
    command => 'bash -e wget -qO- https://dl.packager.io/srv/opf/openproject-ce/key | apt-key add -; sudo wget -O /etc/apt/sources.list.d/openproject-ce.list
    https://dl.packager.io/srv/opf/openproject-ce/stable/8/installer/ubuntu/18.04.repo',
    creates => '/etc/apt/sources.list.d/openproject-ce.list',
    path => ['/usr/bin', '/usr/sbin', '/bin'],
  }~>
  package { 'openproject' :
    ensure => latest,
  }

  # Here, someone MUST run `openproject configure`. At least until we
  # configure it via puppet...



  # Setup Nginx
  nginx::resource::server { 'insidan.holgerspexet.se':
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
}
