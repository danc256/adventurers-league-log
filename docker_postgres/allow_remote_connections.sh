#!/bin/sh

# Enable external password access to all hosts
echo "host all  all    0.0.0.0/0  md5" >> "$PGDATA/pg_hba.conf"
