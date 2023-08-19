#!/bin/bash
set -e

sed -i 's/#port = 5432/port = 5442/' /var/lib/postgresql/data/pgdata/postgresql.conf
pg_ctl -w restart -o"-p 5442"
