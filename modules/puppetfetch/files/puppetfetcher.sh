#!/bin/bash
# This script fetches the puppet configuration for
# holgerspexet.lysator.liu.se from github and applies it
#
# Make sure to add the servers public key as a github deploy key

export HOME=/root/
PATH=/opt/puppetlabs/bin:$PATH


# Initialize repo if not already there
if [ ! -d /opt/holger-puppet ]; then 
    git clone --recursive git@github.com:holgerspexet/holger-puppet.git /opt/holger-puppet > /dev/null || exit 1
fi

# Update repo
cd  /opt/holger-puppet || exit 1 
git pull > /dev/null || exit 1
git submodule update --recursive --remote > /dev/null  || exit 1

# Run puppet and hope all is well
uptime >> /root/last_puppet_run.log
puppet apply --modulepath=/opt/holger-puppet/modules/ /opt/holger-puppet/manifests/site.pp >> /root/last_puppet_run.log

PUPPET_RETURN_VALUE=$?
PROMETHEUS_DUMP_PATH=/var/lib/prometheus-dropzone


echo puppet_last_apply_time $(date +%s) > $PROMETHEUS_DUMP_PATH/puppet_last_apply_time.prom.dubbelbuffer
mv $PROMETHEUS_DUMP_PATH/puppet_last_apply_time.prom.dubbelbuffer $PROMETHEUS_DUMP_PATH/puppet_last_apply_time.prom

echo puppet_return $PUPPET_RETURN_VALUE > $PROMETHEUS_DUMP_PATH/puppet_return.prom.dubbelbuffer
mv $PROMETHEUS_DUMP_PATH/puppet_return.prom.dubbelbuffer $PROMETHEUS_DUMP_PATH/puppet_return.prom



