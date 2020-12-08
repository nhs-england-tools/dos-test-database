include $(VAR_DIR)/platform-texas/default/account-live-k8s-nonprod.mk

# ==============================================================================
# Service variables

DB_INSTANCE = $(PROJECT_GROUP_SHORT)-$(PROJECT_NAME_SHORT)-$(DB_INSTANCE_NAME)-$(ENVIRONMENT)
#DB_HOST = [secret] $(DB_INSTANCE).aaaaaaaaaaaa.$(AWS_REGION).rds.amazonaws.com
DB_PORT = 5432
DB_NAME = postgres
DB_USERNAME = postgres
#DB_PASSWORD = [secret]

# ==============================================================================
# Infrastructure variables

DEPLOYMENT_STACKS = data
INFRASTRUCTURE_STACKS = database
