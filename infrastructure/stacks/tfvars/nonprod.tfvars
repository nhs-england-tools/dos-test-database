####################################################################################
# !!!!!!N O N-P R O D!!!!!!!!!
####################################################################################

####################################################################################
# TERRAFORM PLATFORM INFRASTRUCTURE COMMON
####################################################################################
terraform_platform_state_s3_bucket = "nhsd-texasplatform-terraform-state-store-live-lk8s-nonprod"

####################################################################################
# AWS COMMON
####################################################################################
aws_profile    = "nhsd-ddc-exeter-texas-live-k8s-nonprod"
aws_region     = "eu-west-2"
cloud_env_type = "nonprod"

####################################################################################
# TEXAS COMMON
####################################################################################
billing_code_tag   = "k8s-nonprod.texasplatform.uk"
environment_tag    = "lk8s-nonprod.texasplatform.uk"
nhs_programme_name = "uec-dos-test-database-service"
nhs_project_name   = "uec-dos-test-database-service"
service_name       = "uec-dos-test-database-service"
service_prefix     = "uec-dos-test-database-service"

####################################################################################
# SERVICE COMMON
####################################################################################
version_tag = "0.1"

###################################################################################
# SECURITY GROUPS
####################################################################################
security-groups-k8s_terraform_state_key = "security-groups-k8s/terraform.tfstate"

####################################################################################
# VPC
####################################################################################
vpc_terraform_state_key = "vpc/terraform.tfstate"

####################################################################################
# SERVICE DOS RDS POSTGRES
####################################################################################
db_name                       = "postgres"
db_max_connections            = "100"