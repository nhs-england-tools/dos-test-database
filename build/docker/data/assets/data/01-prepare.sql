\set database_name `echo "$DB_DOS_NAME"`
\set pathwaysdos_username `echo "$DB_DOS_USERNAME"`
\set pathwaysdos_password `echo "$DB_DOS_PASSWORD"`

CREATE ROLE :pathwaysdos_username PASSWORD :'pathwaysdos_password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE :pathwaysdos_username SET search_path = pathwaysdos;

CREATE ROLE pathwaysdos_auth password :'pathwaysdos_password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE pathwaysdos_auth SET search_path = pathwaysdos, extn_pgcrypto;

CREATE ROLE pathwaysdos PASSWORD :'pathwaysdos_password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE pathwaysdos SET search_path = pathwaysdos, extn_pgcrypto;

CREATE ROLE pathwaysdos_auth_grp;
CREATE ROLE pathwaysdos_read_grp;
CREATE ROLE pathwaysdos_write_grp;

GRANT pathwaysdos_auth_grp TO pathwaysdos_auth;
GRANT pathwaysdos_read_grp TO pathwaysdos;
GRANT pathwaysdos_write_grp TO pathwaysdos;

CREATE DATABASE :database_name WITH OWNER :pathwaysdos_username;
