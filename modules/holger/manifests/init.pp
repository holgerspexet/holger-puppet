class holger {
  include ntp
  include ::holger::puppetfetch
  include ::holger::openproject
  include ::holger::byggerom
  class { '::lyslogclient': }

  package { ['fail2ban',
             'unattended-upgrades',
             'openssh-server',
            ]:
              ensure => 'latest',
  }

  cron { 'reboot weekly':
    command => '/sbin/reboot',
    weekday => '1',
    hour    => '3',
    minute  => '30',
  }
}
