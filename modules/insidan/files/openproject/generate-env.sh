#!/bin/bash
# Generates the .env file for the OpenProject compose stack.
# Usage: generate-env.sh <fqdn> <target-env-file>
#
# Generates random secrets for SECRET_KEY_BASE, POSTGRES_PASSWORD and
# COLLABORATIVE_SERVER_SECRET. The file is only generated once (puppet
# guards with `creates`), so restarts keep their secrets.
set -euo pipefail

fqdn="$1"
target="$2"

secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 48)
dbpass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24)
hocussecret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

cat > "$target" <<EOF
TAG=17-slim
OPENPROJECT_HTTPS=true
OPENPROJECT_HSTS=true
OPENPROJECT_HOST__NAME=${fqdn}
OPENPROJECT_ADDITIONAL__HOST__NAMES=web
OPENPROJECT_RAILS__RELATIVE__URL__ROOT=
IMAP_ENABLED=false
POSTGRES_VERSION=17
POSTGRES_PASSWORD=${dbpass}
DATABASE_URL=postgres://postgres:${dbpass}@db/openproject?pool=20&encoding=unicode&reconnect=true
SECRET_KEY_BASE=${secret}
COLLABORATIVE_SERVER_URL=wss://${fqdn}/hocuspocus
COLLABORATIVE_SERVER_SECRET=${hocussecret}
RAILS_MIN_THREADS=4
RAILS_MAX_THREADS=16
EOF

chmod 600 "$target"
