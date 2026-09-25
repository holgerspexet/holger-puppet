#!/bin/bash
# Dumps the OpenProject database from the podman-compose postgres container.

FILE=/pg_dump/`date +"%Y%m%d%H%M"`_pg_dump.sql

CONTAINER=$(podman ps --filter name=db --format "{{.Names}}" | head -n1)
if [ -z "$CONTAINER" ]; then
    echo "no db container running, skipping dump" >&2
    exit 1
fi

podman exec "$CONTAINER" pg_dump -U postgres openproject -F p > ${FILE}
find /pg_dump -maxdepth 1 -mtime +14 -name "*_pg_dump.sql" -exec rm '{}' ';'
