class holger::puppetfetch {
  file { '/opt/puppetfetcher.sh':
    owner  => 'root',
    group  => 'root',
    mode   => '744',
    source => 'puppet:///modules/holger/puppetfetcher.sh',
  }
  cron { 'puppetfetcher':
    ensure  => present,
    command => '/opt/puppetfetcher.sh',
    user    => root,
    minute  => 55,
  }
}