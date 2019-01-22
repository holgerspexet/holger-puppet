node 'holgerspexet' {
  require ::baseinstall
  require ::puppetfetch
  include ::insidan
}

node 'holgerspexet-public' {
  require ::baseinstall
}
