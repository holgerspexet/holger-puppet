class baseinstall (
  # The fqdn of this machine, from facts by default. Manages hostname
  # resolution so that $facts['networking']['fqdn'] is actually correct.
  String $fqdn = $facts['networking']['fqdn'],
) {
  $shortname = split($fqdn, '.')[0]

  include ::nftables

  package { ['fail2ban',
             'unattended-upgrades',
             'openssh-server',
             'qemu-guest-agent',
             'tmux',
             'tree',
            ]:
              ensure => 'installed',
  }

  # The fqdn must resolve to this host so the networking facts (and
  # thereby every service that takes its name from facts) stay sane
  # across reboots.
  host { $fqdn:
    ensure       => present,
    ip           => '127.0.1.1',
    host_aliases => [$shortname],
  }

  file { '/etc/hostname':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${fqdn}\n",
    notify  => Exec['apply-hostname'],
  }

  exec { 'apply-hostname':
    command     => '/usr/bin/hostname -F /etc/hostname',
    refreshonly => true,
    path        => ['/usr/bin', '/bin'],
  }

  # Remove old puppet reports that waste disk space
  tidy { '/opt/puppetlabs/puppet/cache/reports':
         age     => '30d',
         matches => '*.yaml',
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
}
