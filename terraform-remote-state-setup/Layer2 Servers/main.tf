############################################################
# Terraform Configuration for Web Server Security Group
#
# Description :
#   - Retrieves VPC information from remote Terraform state
#   - Creates a security group for web servers:
#       * Allows HTTP (port 80) from anywhere
#       * Allows SSH (port 22) from internal VPC CIDR
#       * Allows all outbound traffic
#   - Stores state remotely in S3
#
# Author      : Azizbek Imamkulov
# Environment : Development
# Region      : us-east-1
# Backend     : S3 (azizbek-imamkulov-terraform-state)
# Depends on  : dev/network/terraform.tfstate
#
# Outputs:
#   - Security Group ID for web servers
############################################################


provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "azizbek-imamkulov-terraform-state"
    key    = "dev/servers/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "azizbek-imamkulov-terraform-state"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "webserver" {
  name   = "Webserver Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "web.server.sg"
    Owner = "Azizbek Imamkulov"
  }
}

output "webserver_sg.id" {
  value = aws_security_group.webserver.id
}

