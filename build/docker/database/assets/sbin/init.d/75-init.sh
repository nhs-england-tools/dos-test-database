#!/bin/bash
set -e

mkdir -p /var/lib/postgresql/tablespace/{dbs,indexes}
chown -R $SYSTEM_USER_UID:$SYSTEM_USER_GID /var/lib/postgresql/tablespace
