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

download-sql-dump:
	# TODO: Downlaod the latest DoS database SQL dump file
	# INPUT:
	#		- link to an SQL dump file

populate-database:
	# TODO: Deploy k8s job to run the scripts agains the RDS instance
	#		- instance name / location

# ==============================================================================

.SILENT:
