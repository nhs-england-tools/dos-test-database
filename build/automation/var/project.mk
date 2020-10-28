PROGRAMME = uec
PROJECT_GROUP = uec/tools
PROJECT_GROUP_SHORT = uec-tools
PROJECT_NAME = dos-test-database
PROJECT_NAME_SHORT = dtdb
PROJECT_DISPLAY_NAME = DoS Test Database

ROLE_PREFIX = UECDoSAPI
SERVICE_TAG = $(PROJECT_GROUP_SHORT)
PROJECT_TAG = $(PROJECT_NAME)

GIT_TASK_BRANCH_PATTERN = task/[A-Z]{2,5}-[0-9]{1,5}_[A-Za-z0-9_]{4,32}

DOCKER_REPOSITORIES =
SSL_DOMAINS_PROD =

# ==============================================================================

DOS_DATABASE_VERSION := 5-4-0
