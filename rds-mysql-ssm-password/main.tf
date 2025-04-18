provider "aws" {
  region = "us-east-1"
}

resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"
}

resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}


data "aws_ssm_parameter" "my_rds_password" {
  name       = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password]
}


resource "aws_db_instance" "default" {
  identifier           = "prod-rds"
  allocated_storage    = 20
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "administrator"
  password             = data.aws_ssm_parameter.my_rds_password.value
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  apply_immediately    = true
}

output "rds_password" {
  value     = data.aws_ssm_parameter.my_rds_password.value
  sensitive = true
}
