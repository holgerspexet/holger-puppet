node 'holgerspexet' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::insidan
  include ::arkivet
  include ::citat
  include ::sjung
  include ::lysbackup
}

node 'holgerspexet-public' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::wordpress
  include ::lysbackup
}
