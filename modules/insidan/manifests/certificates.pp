class insidan::certificates {
  class { '::letsencrypt':
    email => 'hx@hx.ax', # Putting in my personal email for now
  }

  letsencrypt::certonly { 'insidan.holgerspexet.se':
    domains => [ 'insidan.holgerspexet.se',
                 'holgerspexet.lysator.liu.se',
                 'holgerspexet.se',
                 'www.holgerspexet.se',
               ],
    suppress_cron_output => true,
    cron_success_command => '/bin/systemctl restart nginx',
  }
}
