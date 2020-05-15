module "db" {
    source = "terraform-aws-modules/rds/aws"
    version = "~> 2.0"

    identifier = "${var.instance_db_name}-${var.cloud_env_type}"

    engine = "postgres"
    engine_version = "11.6"
    instance_class = "db.t3.micro"
    allocated_storage = 10

    name     = var.db_name
    username = "postgres"
    password = "YourPwdShouldBeLongAndSecure!"
    port     = "5432"

    #iam_database_authentication_enabled = true

    vpc_security_group_ids = ["${var.vpc_security_group}"]

    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_window      = "03:00-06:00"

    # disable backups to create DB faster
    backup_retention_period = 0

    tags = {
        Name        = "${var.instance_db_name}-${var.cloud_env_type}"
        BillingCode = var.billing_code_tag
        Environment = var.environment_tag
        Version     = var.version_tag
        Service     = var.service_name
    }

  # DB subnet group (create own)
  subnet_ids = var.private_subnets_ids

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.instance_db_name

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name         = "max_connections"
      value        = var.db_max_connections
      apply_method = "pending-reboot"
    },
    {
      name         = "client_encoding"
      value        = "UTF8"
      apply_method = "pending-reboot"
    },
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "timezone"
      value        = "GB"
      apply_method = "pending-reboot"
    },
    {
      name         = "rds.log_retention_period"
      value        = "5760"
      apply_method = "pending-reboot"
    },
    {
      name         = "ssl"
      value        = "1"
      apply_method = "immediate"
    }
  ]
}