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

  # Certificate for the machine itself plus the old lysator name.
  # NOTE: holgerspexet.se / www.holgerspexet.se belong to the public
  # wordpress box (holgerspexet-public) and its DNS points there —
  # the standalone ACME challenge for them can never pass from this
  # machine, so they must NOT be in this certificate.
  class { 'insidan::certificates':
    domains => ['insidan.holgerspexet.se',
                'holgerspexet.lysator.liu.se',
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

  # Parked until (a) the /storage backing is hooked up and (b) the
  # holger-archive deploy key works on this machine again (the
  # git@helvetesjavlaskit.github.com ssh alias). When it returns it
  # brings its vcsrepo, build, service and the /arkivet/ nginx
  # locations. The shared holger user + /storage live in citat while
  # arkivet is parked.
  #
  # TODO: arkivet's /storage data root needs hooking up to new
  # storage; babelfish is gone.
  #include ::arkivet

  include ::citat
  include ::sjung
  include ::lysbackup
  # Keep forwarding logs to the Lysator loghost, as before.
  class { 'lyslogclient':
    forward_to_loghost => true,
  }
  # Parked: small py3.6-era flask/uwsgi board tool (gitlab repo, deploy
  # token baked into its clone URL). No other module depends on it.
  # To revive: uncomment, modernize the module for 26.04 (py3 packages,
  # venv instead of pip --install-option / python3.6 paths) and rotate
  # the gitlab deploy token out of the URL.
  #include ::paragrafryttare

  include ::inventarie
}

# Temporary testbed while the migration runs. Delete this node (and
# the machine) once insidan.holgerspexet.se is fully migrated.
node 'holgerlabb.hx.ax' {
  include ::baseinstall
  include ::puppetfetch
  include ::ssh
  include ::insidan
  # arkivet is parked, see the production node for details; the shared
  # holger user + /storage are declared by citat meanwhile.
  #include ::arkivet
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
