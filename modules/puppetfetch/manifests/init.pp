class puppetfetch {
  file { '/opt/puppetfetcher.sh':
    owner  => 'root',
    group  => 'root',
    mode   => '744',
    source => 'puppet:///modules/puppetfetch/puppetfetcher.sh',
  }
  cron { 'puppetfetcher':
    ensure  => present,
    command => '/opt/puppetfetcher.sh',
    user    => root,
    minute  => 55,
  }
  
  tidy { '/opt/puppetlabs/puppet/cache/reports':
    age => '12w',
    recurse => true,
    rmdirs => true,
  }
}
