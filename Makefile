PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/build/automation/init.mk)

# ==============================================================================

create-instance: ## Creates RDS Instance - mandatory: INSTANCE_NAME=[name];
	# TODO: Create an RDS instance from our Terraform module
	# INPUT:
	#		- instance name
	make terraform-apply-auto-approve \
	STACKS=service \
	OPTS="-var-file=../tfvars/nonprod.tfvars \
	-var 'instance_db_name=$(INSTANCE_NAME)'"
	echo -e "\n\033[1mRDS Instance Details\033[00m"
	echo -e "\nEndpoint:"
	aws rds describe-db-instances --db-instance-identifier=$(INSTANCE_NAME)-nonprod | jq -r '.DBInstances[0].Endpoint.Address'
	echo -e "\nUsername:"
	aws rds describe-db-instances --db-instance-identifier=$(INSTANCE_NAME)-nonprod | jq -r '.DBInstances[0].MasterUsername'
	echo -e "\nPassword Secret Endpoint:"
	echo $(INSTANCE_NAME)-nonprod-dos_db_password

download-sql-dump: ## Downloads the latest DoS database dump and gunzips it
	# TODO: Downlaod the latest DoS database SQL dump file
	# INPUT:
	#		- link to an SQL dump file
	make aws-s3-download URI=nhsd-texasplatform-service-dos-lk8s-nonprod/\
	$(shell aws s3 ls s3://nhsd-texasplatform-service-dos-lk8s-nonprod | \
	sort | grep "dos-pg-dump-.*-clean-PU.sql.gz" | tail -n 1 | \
	awk '{print $$4}') \
	FILE=/project/build/docker/data/assets/sql/dos-dump.sql.gz
	gzip -d build/docker/data/assets/sql/dos-dump.sql

build-dos-database-image: ## Builds dos database docker container
	make docker-build NAME=data

create-dos-database-image-repository:
	make docker-login
	make docker-create-repository NAME=data

push-dos-database-image:
	make docker-login
	make docker-push NAME=data

populate-database:
	# TODO: Deploy k8s job to run the scripts agains the RDS instance
	#		- instance name / location

help: ## Show all make targets
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

# ==============================================================================

.SILENT:
.DEFAULT_GOAL := help
