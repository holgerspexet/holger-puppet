#!/bin/bash

FILE=/pg_dump/`date +"%Y%m%d%H%M"`_pg_dump.sql

su postgres -c "pg_dump openproject -F p -f ${FILE}"
find /pg_dump -maxdepth 1 -mtime +14 -name "*_pg_dump.sql" -exec rm '{}' ';'
