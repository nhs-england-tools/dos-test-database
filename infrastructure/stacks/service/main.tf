resource "aws_security_group" "rds-postgres-sg" {
  name        = "${var.instance_db_name}-${var.cloud_env_type}-db-sg"
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

# INGRESS TO RDS POSTGRES FROM EKS #
resource "aws_security_group_rule" "rds_postgres_ingress_from_eks_worker" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds-postgres-sg.id
  source_security_group_id = data.terraform_remote_state.security-groups-k8s.outputs.eks_worker_additional_sg_id
  description              = "Allow access in from Eks-worker to rds postgres"
}

module "dos_db" {
  source         = "../../modules/rds"
  service_prefix = var.service_prefix

  db_name             = var.db_name
  instance_db_name    = var.instance_db_name
  private_subnets_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  cloud_env_type      = var.cloud_env_type


  billing_code_tag   = var.billing_code_tag
  environment_tag    = var.environment_tag
  version_tag        = var.version_tag
  nhs_programme_name = var.nhs_programme_name
  nhs_project_name   = var.nhs_project_name
  service_name       = var.service_name

  vpc_security_group = aws_security_group.rds-postgres-sg.id
  db_max_connections = var.db_max_connections
}
