class holger {
  include ntp
  include ::holger::puppetfetch
  class { '::lyslogclient': }
}
