node 'holgerspexet' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::insidan
}

node 'holgerspexet-public' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::wordpress
}
