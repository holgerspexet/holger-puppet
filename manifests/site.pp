node 'holgerspexet.lysator.liu.se' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::insidan
  include ::arkivet
  include ::citat
  include ::sjung
  include ::lysbackup
  include ::paragrafryttare
  include ::inventarie
}

node 'holgerspexet-public' {
  require ::baseinstall
  require ::puppetfetch
  include ::ssh
  include ::wordpress
  include ::lysbackup
}
