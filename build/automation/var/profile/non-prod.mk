-include $(VAR_DIR)/platform-texas/account-live-k8s-nonprod.mk

# ==============================================================================
# Service variables

DB_NAME=postgres
DB_HOST=test-rds-instance-nonprod.cqger35bxcwy.eu-west-2.rds.amazonaws.com
DB_PORT=5432
DB_USERNAME=postgres
#DB_PASSWORD=password

DOS_TEST_DATABASE_TAG=latest
