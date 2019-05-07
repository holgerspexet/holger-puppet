class wordpress::certificates {
    class { '::letsencrypt':
    email => 'hx@hx.ax', # Putting in my personal email for now
  }

  letsencrypt::certonly { 'holgerspexet.se':
    domains => [ 'holgerspexet.se',
                 'holgerspexet-public.lysator.liu.se',
                 'www.holgerspexet.se',
               ],
    manage_cron => true,
    suppress_cron_output => true,
    cron_hour  => '4',
    cron_minute => '17',
    pre_hook_commands => ['/bin/systemctl stop apache',],
    post_hook_commands => ['/bin/systemctl restart apache || true',],
    # '||true' for initial bootstrap. pls fix
  }
}
