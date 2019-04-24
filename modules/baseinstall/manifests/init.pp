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

  cron { 'reboot weekly':
    command => '/sbin/reboot',
    weekday => '1',
    hour    => '3',
    minute  => '30',
  }

  include prometheus::node_exporter
}
