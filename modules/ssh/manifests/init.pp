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
  ssh_authorized_key { 'hx@hx.ax':
    ensure => present,
    user => 'root',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABgQC79WVDH7CGoS8ZGq2y/OJMhTrJJQ+tEb4SlaPpN6t49XBOLjpHBnOU+8deyDE3p7bOx6oHMY4Cj6qZ5yBPcyrPpDuYeDxsY4jL2LVFz9PIAlfONYy2FvsSXGsKkspx34z3ef/lZg28fMidt666iJArdxjCpnfmJ/6udOvbZOJ97ixfF8/iJ0pYHx/oasAj7TNXtaglXB0yUPJDsZSm6dg0n70w6gqANW6Ef6wKoIlVKVb1XThVBuqujsoCQ2ZXm4xj+UyDDvNYdLO6+ZZbuesxw8rmdQ3zWie9vLU+Kp7VVDrHBVsLjWptOu+yx0/IMDhsxTMHnRGNluqv4uT8TXTWccyXz3GtHOy/50lA7AL70IaF6/NjHzXCH3YXxztDSs5UitlDPsypuZrYVPQqAanoHRwLyUvxhCp4wHGqLrMnCgcz/3Rj4bFEf8KW7Rm9ypKlpe0z6r9gvd0el04Uf0p8GFjNzUtd3EAovNKIhEHbqtH/VHzGZUk1nffXYe/WWRc=',
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

    # Johan Gustavsson (hemma dator)
  ssh_authorized_key { 'johan.bo.gustavsson@gmail.com':
    ensure => present,
    user => 'root',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDPdY2f9EESRbljt8vdoJhqaDE/Pc7RNMXuZZqujpPuUwH0c4C+sn5Q3uXJuycCjxDLg/se8k5x/K2hw6hTyIjkl1seO8b7fWPEuCnXHsqd+jYrN0wXHBRKyFS7N21ey5VMYZ+l3jmAMk6qABUF9YGVidw9JUzK6ew95iF0taLR9hG+h5Q2WI2TtuAjyEoDPEeEjYTS8d2njGnV2KzWv6HTQilAXSwB39ygAqVio+cxlxN631kyopsJPwf1ExbyM4CJCAH+/yMRVRZYdG6s5k/Dhv3VPMIEzVkfsKVeTTR2p+LJ2Onvr0ZpuEomL18mrxQwbB+SqGWaoMpkQlp5dsC7',
    }
    
    # Filip Polbratt
  ssh_authorized_key { 'octol@ronon':
    ensure => present,
    user => 'root',
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDFPUG9+Kq5JMTnW4mlK3pquEC23juTr3vNAB0naH2uzUcsI2vr4RUsf9+BcWopHRgXzAsWdWfZMrryzyxqLkZX6+qY7OVX4bVt/LghSZBVg6hB8L0LzqWZWwMvqkDlAiNCuTGV+1z3Bw2Q9izSUGRqjCxdALtga9ZTpYQlk1iw8odlGIeUvwppi340TNK79KU+Q/6y18MlYN0bVsheUA/OlrWIt4Y8psYB0j7xhjf7jXddA3hIEPq4g1mpzZsIFJuLT4474dk5yqHDNPdKNq2TcfUvx0fCxbLvNDpbIVHewsVJ6rNaPqvKkZp1wioWObVsh4lJVdWjhXTmwJlQIdiD',
    }
}
