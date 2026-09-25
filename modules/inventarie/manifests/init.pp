class inventarie (
  String $hostname = $facts['networking']['fqdn'],
) {
  ::nginx::resource::location { 'inventarie':
    ensure => 'present',
    location => '/inventarie/',
    server => $hostname,
    ssl => true,
    ssl_only => true,
    location_cfg_append => {
      include => 'uwsgi_params',
      uwsgi_pass => 'unix:/tmp/inventarie.sock',
      auth_request => '/holger-auth',
      error_page => "401 = /login?back_url=https%3A%2F%2F${hostname}%2Finventarie%2F",
    },
  }
}
