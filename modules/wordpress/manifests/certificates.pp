class wordpress::certificates {
    class { '::letsencrypt':
    email => 'webmaster@holgerspexet.se',
  }

  letsencrypt::certonly { 'holgerspexet.se':
    domains => [ 'holgerspexet.se',
                 'holgerspexet-public.lysator.liu.se',
                 'www.holgerspexet.se',
               ],
    manage_cron => true,
    cron_output => 'log',
    cron_hour  => '4',
    cron_minute => '17',
    pre_hook_commands => ['/bin/systemctl stop apache',],
    post_hook_commands => ['/bin/systemctl restart apache || true',],
    # '||true' for initial bootstrap. pls fix
  }
}
