class baseinstall {
  include ntp
  class { '::lyslogclient': }

  package { ['fail2ban',
             'unattended-upgrades',
             'openssh-server',
             'qemu-guest-agent',
             'tmux',
             'tree',
            ]:
              ensure => 'latest',
  }

  # Remove old puppet reports that waste disk space
  tidy { '/var/cache/puppet/reports':
         age     => '30d',
         matches => "*.yaml",
         recurse => true,
         rmdirs  => false,
         type    => mtime,
  }


  cron { 'reboot weekly':
    command => '/sbin/reboot',
    weekday => '1',
    hour    => '3',
    minute  => '30',
  }

  file { '/var/lib/prometheus-dropzone':
    ensure => directory,
  }

  class { '::prometheus::node_exporter': 
    extra_options => '--collector.textfile.directory=/var/lib/prometheus-dropzone',
    require => File['/var/lib/prometheus-dropzone'],
  }
}
