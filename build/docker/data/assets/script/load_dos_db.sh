#! /bin/sh.

# Extracting DoS database
gzip -d $SQL_DIR/dos-dump.sql.gz

# PSQL to load DoS Database on to test database
psql -f $SQL_DIR/dos-dump.sql --host $PGHOST --port $PGPORT --username $PGUSERNAME --dbname $PGDATABASENAME
