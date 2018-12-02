class lyslogclient
{
  file {
    '/etc/rsyslog.conf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/lyslogclient/rsyslogd.conf';
  }

  service {
    'rsyslog':
      ensure    => 'running',
      enable    => true,
      pattern   => 'syslog',
      subscribe => File['/etc/rsyslog.conf'];
  }

  cron {
    'syslog_mark':
      ensure  => present,
      command => '/usr/bin/logger mark',
      user    => root,
      minute  => 33,
  }
}
