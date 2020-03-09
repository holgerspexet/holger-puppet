#!/bin/bash

# This script exit with code 0 if a new version should be fetch
# and with any other exit code if no new version is avilable.

set -x

binaryPath="$1"

if test -f "$binaryPath"; then
    installedVersion="$("$binaryPath" -version)"
    releasedVersion="$(curl https://api.github.com/repos/holgerspexet/holger-quotes/releases/latest | grep '"tag_name"\s*:\s*' | grep -o [0-9.-]*)"
    test $releasedVersion != $installedVersion
else
    exit 0  # new version is considered avilable if binary does not exists
fi