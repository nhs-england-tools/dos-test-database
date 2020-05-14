##################################################################################
# INFRASTRUCTURE COMPONENT VERSION
##################################################################################
variable "version_tag" {
  description = "The infrastructure component version assigned by Texas development. The version MUST be incremented when changed <major version>.<minor version>"
  default     = "1.0"
}

variable "cloud_env_type" { description = "The cloud enviroment type e.g. nonprod, prod" }

####################################################################################
# TEXAS COMMON
####################################################################################
variable "billing_code_tag" {
  description = "The tag used to identify component for billing purposes"
}

variable "environment_tag" {
  description = "The tag used to identify component environment"
}

variable "service_prefix" {
  description = "Prefix used for naming resources"
}

variable "nhs_programme_name" {
  description = "The NHS Programme using the resource"
}

variable "nhs_project_name" {
  description = "The NHS Project using the resource"
}

variable "service_name" {
  description = "The tag used to identify the service the resource belongs to"
}

############################
# DoS DATABASE
############################

# The following variables are all read from the variables-<environment>.tfvars.json file
variable "instance_db_name" {}

variable "db_name" {}

variable "db_max_connections" {}

variable "vpc_security_group" {}

variable "private_subnets_ids" {
  default     = []
  description = "List of private subnet ids where the RDS nodes and backend services live."
}