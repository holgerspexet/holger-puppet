class insidan::certificates {
  class { '::letsencrypt':
    email => 'hx@hx.ax', # Putting in my personal email for now
  }

  letsencrypt::certonly { 'insidan.holgerspexet.se':
    domains => [ 'insidan.holgerspexet.se',
                 'holgerspexet.lysator.liu.se',
               ],
    manage_cron => true,
    cron_hour  => '4',
    cron_minute => '13',
    pre_hook_commands => ['/bin/systemctl stop nginx',],
    post_hook_commands => ['/bin/systemctl restart nginx',],
  }
}
