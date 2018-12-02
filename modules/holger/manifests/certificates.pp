class holger::certificates {
  include nginx
  class { '::letsencrypt':
    email => 'hx@hx.ax', # Putting in my personal email for now
    
  }

  letsencrypt::certonly { 'insidan.holgerspexet.se':
    domains => [ 'insidan.holgerspexet.se',
                 'holgerspexet.lysator.liu.se'],
    manage_cron => true,
    suppress_cron_output => true,
    notify => Service['nginx'],
  }
}
