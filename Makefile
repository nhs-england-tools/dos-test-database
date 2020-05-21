PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/build/automation/init.mk)

DOS_DB_FILE=$(shell aws s3 ls s3://nhsd-texasplatform-service-dos-lk8s-nonprod | sort | grep "dos-pg-dump-.*-clean-PU.sql.gz" | tail -n 1 | awk '{ print $$4 }')

# ==============================================================================

create-instance: # Creates RDS Instance - mandatory: INSTANCE_NAME=[name];
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

download-sql-dump: # Downloads the latest DoS database dump and gunzips it
	make aws-s3-download \
		URI=nhsd-texasplatform-service-dos-lk8s-nonprod/$(DOS_DB_FILE) \
		FILE=/project/build/docker/data/assets/sql/dos-dump.sql.gz


build-dos-database-image: # Builds dos database docker container
	make docker-build NAME=data

create-dos-database-image-repository: # Creates the ECR repository
	make docker-login
	make docker-create-repository NAME=data

push-dos-database-image: # Pushes the database image to the ECR repository
	make docker-login
	make docker-push NAME=data

docker-populate-local-database-test:
	make docker-compose-start-single-service NAME=test-db YML=$(DOCKER_DIR)/docker-compose-test.yml
	make docker-compose-start-single-service NAME=data YML=$(DOCKER_DIR)/docker-compose-test.yml

docker-clean-local-test-database:
	docker stop $(docker container ls | grep -P '.*test-database/data.*'| awk '{ print $1 }')
	docker container rm $(docker container ls -a | grep -P '.*test-database/data.*'| awk '{ print $1 }')

populate-database:
	# TODO: Deploy k8s job to run the scripts agains the RDS instance
	#		- instance name / location

# ==============================================================================

.SILENT:
