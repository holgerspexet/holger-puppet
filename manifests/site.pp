node 'holgerspexet' {
  require ::baseinstall
  require ::puppetfetch
  include ::holger
}

node 'holgerspexet-public' {
  require ::baseinstall
}
