class lysbackup {
  package { 'borgbackup':
    ensure => 'installed',
  }

  file {'/opt/lysbackup/':
    ensure  => directory,
    recurse => true,
    mode => '0755',
    source => 'puppet:///modules/lysbackup/opt/lysbackup/',
  }

  cron { 'borgbackup':
    ensure => present,
    command => '/usr/bin/python3 /opt/lysbackup/backup.py holgerspexet-backup',
    user => root,
    minute => '05',
    hour => '04',
  }
}
