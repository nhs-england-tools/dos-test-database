PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/build/automation/init.mk)

# ==============================================================================

download: project-config # Download DoS database dump file
	eval $$(make aws-assume-role-export-variables)
	make aws-s3-download \
		URI=nhsd-texasplatform-service-dos-lk8s-nonprod/dos-pg-dump-$(DOS_DATABASE_VERSION)-clean-PU.sql.gz \
		FILE=build/docker/data/assets/sql/dos-database-dump.sql.gz

build: project-config # Build DoS database image
	make docker-build NAME=data

start: project-start # Start service locally

stop: project-stop # Stop service locally

log: project-log # Print service logs

# ==============================================================================

create-instance: # Creates RDS Instance - mandatory: INSTANCE_NAME=[name];
	make terraform-apply-auto-approve \
		STACKS=service \
		OPTS=" \
			-var-file=../tfvars/nonprod.tfvars \
			-var instance_db_name=$(INSTANCE_NAME) \
		"
	echo -e "\n\033[1mRDS Instance Details\033[00m"
	echo -e "\nEndpoint:"
	aws rds describe-db-instances --db-instance-identifier=$(INSTANCE_NAME)-nonprod | jq -r '.DBInstances[0].Endpoint.Address'
	echo -e "\nUsername:"
	aws rds describe-db-instances --db-instance-identifier=$(INSTANCE_NAME)-nonprod | jq -r '.DBInstances[0].MasterUsername'
	echo -e "\nPassword Secret Endpoint:"
	echo $(INSTANCE_NAME)-nonprod-dos_db_password


destroy-instance: # Destroys RDS Instance - mandatory: INSTANCE_NAME=[name];
	make terraform-destroy-auto-approve \
		STACKS=service \
		OPTS=" \
			-var-file=../tfvars/nonprod.tfvars \
			-var instance_db_name=$(INSTANCE_NAME) \
		"

create-dos-database-image-repository: # Creates the ECR repository
	make docker-login
	make docker-create-repository NAME=data

push-dos-database-image: # Pushes the database image to the ECR repository
	make docker-login
	make docker-push NAME=data

populate-database: # Deploys a kubernetes job to populate the RDS database - mandatory: INSTANCE_NAME=[name];
	export INSTANCE_NAME=$(INSTANCE_NAME) && \
	make k8s-deploy-job STACK=service PROFILE=non-prod

delete-populate-database-k8s-deployment: # Delete kubernetes deployment for populate database job - mandatory: INSTANCE_NAME=[name];
	export INSTANCE_NAME=$(INSTANCE_NAME) && \
	make k8s-undeploy-job STACK=service PROFILE=non-prod

# ==============================================================================

.SILENT:
