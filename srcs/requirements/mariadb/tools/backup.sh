#!/bin/bash
# Backup MariaDB container to ./backup.sql
CONTAINER=mariadb-basic
USER=root
PASS=rootpass
DB=mydb

docker exec $CONTAINER \
  mysqldump -u$USER -p$PASS $DB > backup.sql

echo "Backup saved to backup.sql"
