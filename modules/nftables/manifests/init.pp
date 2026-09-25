# Handrolled nftables firewall. No ufw. Ever.
#
# Deployed as a static ruleset: /etc/nftables.conf is loaded wholesale by
# `nft -f`, which replaces everything. The ruleset allows ssh, http and
# https inbound, everything else inbound is dropped, output is free.

class nftables {
  package { 'nftables':
    ensure => 'installed',
  }

  # Purged from existence, as nature intended.
  package { 'ufw':
    ensure => 'absent',
  }

  file { '/etc/nftables.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    source  => 'puppet:///modules/nftables/nftables.conf',
    notify  => Exec['nftables-reload'],
    require => Package['nftables'],
  }

  exec { 'nftables-reload':
    command     => '/usr/sbin/nft -f /etc/nftables.conf',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }
  ~> exec { 'podman-network-reload':
    # The conf starts with `flush ruleset`, which also wipes the NAT
    # rules podman's netavark installs for its networks. Re-apply them
    # on nodes that run containers (no-op where podman is absent).
    #
    # NB: a manual `systemctl restart nftables` on a live box flushes
    # the container NAT on its own; run `podman network reload --all`
    # after it.
    command     => '/usr/bin/podman network reload --all',
    refreshonly => true,
    onlyif      => '/usr/bin/test -x /usr/bin/podman',
  }

  service { 'nftables':
    ensure  => running,
    enable  => true,
    require => [
      Package['nftables'],
      File['/etc/nftables.conf'],
    ],
  }
}
