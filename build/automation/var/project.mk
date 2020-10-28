PROGRAMME = uec
PROJECT_GROUP = uec/tools
PROJECT_GROUP_SHORT = uec-tools
PROJECT_NAME = test-database
PROJECT_NAME_SHORT = tdb
PROJECT_DISPLAY_NAME = DoS Test Database

ROLE_PREFIX = UECTools
SERVICE_TAG = $(PROJECT_GROUP_SHORT)
PROJECT_TAG = $(PROJECT_NAME)

GIT_TASK_BRANCH_PATTERN = task/[A-Z]{2,5}-[0-9]{1,5}_[A-Za-z0-9_]{4,32}

DOCKER_REPOSITORIES =
SSL_DOMAINS_PROD =

# ==============================================================================

DOS_DATABASE_VERSION := 5-4-0
