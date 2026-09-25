class insidan::byggerom (
  # Static "bygg om" page served on its own vhost (historically
  # holgerspexet.se / www). The certificate used is the one for the
  # machine fqdn; on the production box the insidan certificate covers
  # the holgerspexet.lysator.liu.se name as well.
  Array[String] $server_names = ['holgerspexet.se', 'www.holgerspexet.se'],
  String $certname = $facts['networking']['fqdn'],
) {
  include ::nginx
  # Setup Nginx
  nginx::resource::server { 'byggerom':
    server_name => $server_names,

    www_root => '/srv/byggerom/',

    # Encrypt everything
    ssl_redirect => true,
    ssl   => true,
    ssl_cert  => "/etc/letsencrypt/live/${certname}/fullchain.pem",
    ssl_key   => "/etc/letsencrypt/live/${certname}/privkey.pem",

    # Forward secret stuff
    proxy_set_header => ["X-Forwarded-Proto \$scheme",
                         "X-Forwarded-Host \$host",
                         "X-Forwarded-Server \$host",
                         "X-Forwarded-For \$proxy_add_x_forwarded_for",],
    ssl_protocols            => 'TLSv1.2 TLSv1.3',
    ssl_ciphers              => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256',
    ssl_prefer_server_ciphers => 'on',
  }

  file { '/srv/byggerom':
    ensure  => directory,
    recurse => true,
    mode    => '0755',
    source  => 'puppet:///modules/insidan/byggerom/',
  }
}
