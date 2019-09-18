class sjung {
  vcsrepo { '/srv/sjung':
    ensure   => latest,
    provider => git,
    source   => "https://github.com/holgerspexet/sjung.git"
  }

  ::nginx::resource::location { 'sjung':
    ensure => present,
    location => '/sjung/',
    root => '/srv/sjung/'
    server => 'insidan.holgerspexet.se',
    ssl => true,
    ssl_only => true,
   }
  include nginx
}
