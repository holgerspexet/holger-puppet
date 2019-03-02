node 'holgerspexet' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::insidan
  include ::arkivet
}

node 'holgerspexet-public' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::wordpress
}
