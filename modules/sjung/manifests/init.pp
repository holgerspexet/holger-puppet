class sjung {
  vcsrepo { '/srv/sjung':
    ensure   => latest,
    provider => git,
    source   => "https://github.com/holgerspexet/sjung.git"
  }

  ::nginx::resource::location { 'sjung':
    ensure => present,
    location => '/sjung/',
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
    location_cfg_append => {
      alias => '/srv/sjung/',
    },
   }
  include nginx
}
