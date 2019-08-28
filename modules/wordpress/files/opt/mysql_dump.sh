#!/bin/bash

FILE=/mysql_dump/`date +"%Y%m%d%H%M"`_mysql_dump.sql

mysqldump -u wordpressuser -phunter2 holgerwordpress > ${FILE}

find /mysql_dump -maxdepth 1 -mtime +14 -name "*_mysql_dump.sql" -exec rm '{}' ';'
