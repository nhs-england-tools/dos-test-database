-include $(VAR_DIR)/platform-texas/account-live-k8s-nonprod.mk

# ==============================================================================
# Service variables

DB_INSTANCE = $(PROJECT_GROUP_SHORT)-$(PROJECT_NAME_SHORT)-$(NAME)-$(PROFILE)
DB_HOST = $(DB_INSTANCE).cqger35bxcwy.eu-west-2.rds.amazonaws.com
DB_PORT = 5432
DB_NAME = postgres
DB_USERNAME = postgres
#DB_PASSWORD = [secret]

# ==============================================================================
# Infrastructure variables

DEPLOYMENT_STACKS = data
INFRASTRUCTURE_STACKS = database
