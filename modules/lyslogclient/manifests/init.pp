class lyslogclient (
  # Kept for the reference of what we do NOT do anymore: logs are not
  # forwarded anywhere by default. Flip to true to re-enable the
  # loghost forwarding of days past.
  Boolean $forward_to_loghost = false,
) {
  file {
    '/etc/rsyslog.conf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/lyslogclient/rsyslogd.conf';
  }

  file { '/etc/rsyslog.d/60-loghost.conf':
    ensure  => $forward_to_loghost ? { true => 'file', false => 'absent' },
    mode    => '0644',
    content => "*.* @loghost.lysator.liu.se\n",
  }

  service {
    'rsyslog':
      ensure    => 'running',
      enable    => true,
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
