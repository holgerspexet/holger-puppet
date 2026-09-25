class insidan::certificates (
  # Certificate name and primary domain default to the machine fqdn.
  # Extra SANs can be passed explicitly where needed.
  String $hostname   = $facts['networking']['fqdn'],
  Array    $domains  = [$facts['networking']['fqdn']],
) {
  class { '::letsencrypt':
    email => 'webmaster@holgerspexet.se',
  }

  letsencrypt::certonly { $hostname:
    domains     => $domains,
    manage_cron => true,
    cron_hour   => '4',
    cron_minute => '13',
    # '|| true' for the initial bootstrap, when nginx is not even
    # installed yet. pls fix
    pre_hook_commands  => ['/bin/systemctl stop nginx || true',],
    post_hook_commands => ['/bin/systemctl restart nginx || true',],
  }
}
