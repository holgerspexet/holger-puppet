# The production insidan server. The machine fqdn is
# insidan.holgerspexet.se, so all hostname defaults resolve correctly.
#
# insidan::init force-includes insidan::openproject, insidan::byggerom
# and grunkor without parameters, so those are declared explicitly
# here instead of via include ::insidan.
node 'insidan.holgerspexet.se' {
  include ::baseinstall
  include ::puppetfetch
  include ::ssh

  # Certificate for the machine itself plus the old lysator name and
  # the byggerom vhost names (the old setup served holgerspexet.se
  # with a non-matching certificate).
  class { 'insidan::certificates':
    domains => ['insidan.holgerspexet.se',
                'holgerspexet.lysator.liu.se',
                'holgerspexet.se',
                'www.holgerspexet.se',
               ],
  }

  # OpenProject from the official containers via podman-compose (the
  # deb packages are dead on 26.04). Migrate the data per
  # disaster-recovery.md, section "OpenProject: deb -> compose".
  class { 'insidan::openproject':
    mode => 'podman',
  }

  class { 'insidan::byggerom':
    # server_names default to [holgerspexet.se, www.holgerspexet.se];
    # the certificate to use is the insidan one.
    certname => 'insidan.holgerspexet.se',
  }

  class { 'grunkor': }

  # /storage is the NFS mount from babelfish.
  class { 'arkivet':
    manage_nfs => true,
  }

  include ::citat
  include ::sjung
  include ::lysbackup
  # Keep forwarding logs to the Lysator loghost, as before.
  class { 'lyslogclient':
    forward_to_loghost => true,
  }
  include ::paragrafryttare
  include ::inventarie
}

# Temporary testbed while the migration runs. Delete this node (and
# the machine) once insidan.holgerspexet.se is fully migrated.
node 'holgerlabb.hx.ax' {
  include ::baseinstall
  include ::puppetfetch
  include ::ssh
  include ::insidan
  include ::arkivet
  include ::citat
  include ::sjung
  include ::inventarie
}

# Hosted on a separate machine, managed with the same code.
node 'holgerspexet-public' {
  include ::baseinstall
  include ::puppetfetch
  include ::ssh
  include ::wordpress
  include ::lysbackup
  class { 'lyslogclient':
    forward_to_loghost => true,
  }
}

node default {
  include ::baseinstall
}
