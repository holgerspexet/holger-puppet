class holger {
  include ntp
  include ::holger::puppetfetch
  include ::holger::openproject
  class { '::lyslogclient': }
}
