PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/build/automation/init.mk)

# ==============================================================================

create-instance:
	# TODO: Create an RDS instance from our Terraform module
	# INPUT:
	#		- instance name

download-sql-dump:
	# TODO: Downlaod the latest DoS database SQL dump file
	# INPUT:
	#		- link to an SQL dump file

populate-database:
	# TODO: Deploy k8s job to run the scripts agains the RDS instance
	#		- instance name / location

# ==============================================================================

.SILENT:
