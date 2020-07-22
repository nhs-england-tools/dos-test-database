\set database_name `echo "$DOS_DB_NAME"`
\set pathwaysdos_password `echo "$DOS_DB_PASSWORD"`
\set pathwaysdos_auth_password `echo "$DOS_DB_AUTH_PASSWORD"`
\set release_manager_password `echo "$DOS_DB_RELEASE_MANAGER_PASSWORD"`
\set tablespace_dbs_dir '/var/lib/postgresql/tablespace/dbs'
\set tablespace_indexes_dir '/var/lib/postgresql/tablespace/indexes'

/* Roles */

CREATE ROLE release_manager PASSWORD :'release_manager_password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE release_manager SET search_path = pathwaysdos;

CREATE ROLE pathwaysdos_auth password :'pathwaysdos_auth_password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE pathwaysdos_auth SET search_path = pathwaysdos, extn_pgcrypto;

CREATE ROLE pathwaysdos PASSWORD :'pathwaysdos_password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE pathwaysdos SET search_path = pathwaysdos, extn_pgcrypto;

CREATE ROLE pathwaysdos_auth_grp;
CREATE ROLE pathwaysdos_read_grp;
CREATE ROLE pathwaysdos_write_grp;

/* Grants */

GRANT pathwaysdos_auth_grp TO pathwaysdos_auth;
GRANT pathwaysdos_read_grp TO pathwaysdos;
GRANT pathwaysdos_write_grp TO pathwaysdos;

/* Tablespaces */

CREATE TABLESPACE pathwaysdos_data_01 OWNER release_manager LOCATION :'tablespace_dbs_dir';
CREATE TABLESPACE pathwaysdos_index_01 OWNER release_manager LOCATION :'tablespace_indexes_dir';

/* Databases */

CREATE DATABASE :database_name WITH OWNER release_manager TABLESPACE pathwaysdos_data_01;
