class insidan::byggerom {
  include nginx
  # Setup Nginx
  nginx::resource::server { 'holgerspexet.se':
    server_name => ['holgerspexet.se', 'www.holgerspexet.se', 'holgerspexet.lysator.liu.se'],
    www_root => '/srv/byggerom/',

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

  file { '/srv/byggerom':
    ensure => directory,
    recurse => true,
    mode => '0744',
    source => 'puppet:///modules/insidan/byggerom/',
  }
}
