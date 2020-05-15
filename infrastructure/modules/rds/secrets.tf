resource "aws_secretsmanager_secret" "dos_test_db_password" {
    name                    = "${var.instance_db_name}-${var.cloud_env_type}-dos_db_password"
    description             = "Password for the master Postgres DB user"
    recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "dos_test_db_password" {
    secret_id = aws_secretsmanager_secret.dos_test_db_password.id
    secret_string = random_password.dos_test_db_password.result
}

resource "random_password" "dos_test_db_password" {
    length      = 16
    min_upper   = 2
    min_lower   = 2
    min_numeric = 2
    special     = false
}
