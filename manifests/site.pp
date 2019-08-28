node 'holgerspexet' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::insidan
  include ::arkivet
  include ::lysbackup
}

node 'holgerspexet-public' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::wordpress
  include ::lysbackup
}
