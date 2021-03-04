resource "aws_ssm_parameter" "database_host" {
  name  = "/${var.service_name}/${var.environment_name}/MYSQL_HOST"
  type  = "String"
  value = aws_db_instance.prod.address
}

resource "aws_ssm_parameter" "database_port" {
  name  = "/${var.service_name}/${var.environment_name}/MYSQL_PORT"
  type  = "String"
  value = aws_db_instance.prod.port
}

resource "aws_ssm_parameter" "database_password" {
  name   = "/${var.service_name}/${var.environment_name}/MYSQL_PASS"
  type   = "String"
  value  = random_password.db_admin_password.result
}

resource "aws_ssm_parameter" "database_name" {
  name  = "/${var.service_name}/${var.environment_name}/MYSQL_DATABASE"
  type  = "String"
  value = var.service_name_short
}

resource "aws_ssm_parameter" "database_user" {
  name  = "/${var.service_name}/${var.environment_name}/MYSQL_USER"
  type  = "String"
  value = var.rds_admin_username
}