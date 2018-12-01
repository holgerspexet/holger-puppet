#!/bin/bash
# This script fetches the puppet configuration for
# holgerspexet.lysator.liu.se from github and applies it
#
# Make sure to add the servers public key as a github deploy key

export HOME=/root/

# Initialize repo if not already there
if [ ! -d /opt/holger-puppet ]; then 
    git clone --recursive git@github.com:holgerspexet/holger-puppet.git /opt/holger-puppet > /dev/null || exit 1
fi

# Update repo
cd  /opt/holger-puppet || exit 1 
git pull > /dev/null || exit 1
git submodule update --recursive --remote > /dev/null  || exit 1

# Run puppet and hope all is well
puppet apply --modulepath=/opt/holger-puppet/modules/ /opt/holger-puppet/manifests/site.pp >> /root/last_puppet_run.log


