class ssh {
  user { 'root':
    ensure => present,
    purge_ssh_keys => true,
    home => '/root',
  }

  # Henrik Henriksson
  ssh_authorized_key { 'cartno:000609070933':
    ensure => present,
    user => 'root',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQC3ZnOfK/Yf61BnZFFPynLBU1p3SPAgHyCiSqno7rdrLpcHMO5IeAIZyytY5uhUp9LVxznLePK5LfSZGzAGJ/lIIr/Pg9Gz2l7LFYT4TJahHvSGqB6NPnumVcDmtyh4KYgPHklZ+2QhGukUrMkIiaanc5RMHqC+lfC4p8KslwUTuaFFhexL0c/cwElL6KHpX3HHCBuJ7USBBkYehYvG8+c2+9KxQ8PWBODa6ygVmWo4MLweuBfNv6+6ba/yGGvMQrBZ/JAip3JVy8IEWnh/WZQFeAwPdWQoNPVxlCyvxd0FSj/zKAd9L5bMJB07O4rzsM9/38mSuBukpbkyHs6WAxW+joT01LEHXjtvnIurECnWbf6tYb3mCcmSUqJoNMlAkYICFusqyQuTkvf4dStFP/Epp3NjhOdEnOCmAMEiWYKvDJbAxJwxnu9wkiARJWzkJbYD0ZiHME1BEzYjnlpUnmZ0p36nkDC9ViP+0JIpQUx8leEUyprk9uyyj34o7l+tda5dDVS5mVUJLZiMJpoZ1tMhOkAm3u4lK3myj25bcv2ksZnFe+0hvJUZ1DMnTGXU8S2dCYkgSqKJeaqxNwRtHUzbVWYMYe5PWkOFjm9tEuQiBabw8mjShFF7b2yXX5T10keci2dm23r8PhvuDwAaW3gpleFZie3oR1pSaEscKg3A+w==',
    }

  # Jon Dybeck
  ssh_authorized_key { 'me@tinfoil':
    ensure => present,
    user => 'root',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCfgi+SC6DZIdLC6/GSKAvzP5r+h/OPbQIUFGlu9rTYAM01au31w67CPHf8piQrbcz6qAcSebKtmFRli+Bv9fWS+VC+bRaQ60H0o3RX/YV8zWWDks4a92+IkNSlxRDiF/2gQ1i5rGFcDdkth94iSuyF+oxCe9RhE3GQHvda9rEZi6LiPDQ29TYtof/4RmzDBV3SAGlBvcVPaL0q/syVgMiDTqbBmlsvnc3dPFXGZ2/LzJ1FYljgLusWbddQs7Yn5x7BZhZ7EENRkPDYMTzl+qn6mobZMd8xJawWFq32Ga86z5KXt9Bc09Xr4rQDIt5pUs7XKC92FHhCRLRQ/rVeJDT1',
    }

  # Jon Dybeck
  ssh_authorized_key { 'jondy94@drstest2-105.ad.liu.se':
    ensure => present,
    user => 'root',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC9kMzVie4DwyYqDX+k9SxFTTfE+gcixiON/24rA1qEAp/g1bFkeYO/Apy4xhSxRuQg+4AYE6PfRuAytdhPbWWs/lq6UbXKRm9Tt3aLom6uQmJ3ddQIgCPBtkuCa9rVfEvV1wZkEP3VEn71LQGad0AP1L6wldJszy62p+Vbh8VRUHnvvhsBleEUx2Hq426gzH9QSsiyhiaFBTn921MMmkp+6lPXFZrWipsiJlYZJvhuFrT+d2vMb6ma+BRCP4anWfXIWz8M1L5nb0wIUNGY8HpOa4Tzlf5qUqjO+sQtU/A400HJI12S//DWO3GtPIqfeYfnVffB4hKkqPVvo2eIi6/j',
    }
}
