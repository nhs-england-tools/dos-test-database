resource "aws_security_group" "rds-postgres-sg" {
  name        = "${var.service_prefix}-${var.cloud_env_type}-db-sg"
  description = "Allow connection by appointed rds postgres clients"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name        = "Security Group for access to RDS Postgres"
    BillingCode = var.billing_code_tag
    Environment = var.environment_tag
    Version     = var.version_tag
    Programme   = var.nhs_programme_name
    Project     = var.nhs_project_name
    Terraform   = "true"
    Service     = var.service_name
  }
}

module "dos_db" {
  source             = "../../modules/rds"
  service_prefix     = var.service_prefix

  db_name                 = var.db_name
  private_subnets_ids     = data.terraform_remote_state.vpc.outputs.private_subnets
  cloud_env_type          = var.cloud_env_type


  billing_code_tag   = var.billing_code_tag
  environment_tag    = var.environment_tag
  version_tag        = var.version_tag
  nhs_programme_name = var.nhs_programme_name
  nhs_project_name   = var.nhs_project_name
  service_name       = var.service_name

  vpc_security_group = aws_security_group.rds-postgres-sg.id
  db_max_connections = var.db_max_connections
}
