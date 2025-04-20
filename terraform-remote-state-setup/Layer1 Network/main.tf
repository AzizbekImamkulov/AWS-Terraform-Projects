############################################################
# Terraform Configuration for AWS VPC with S3 Remote State
# 
# Description : 
#   - Creates a VPC with a specified CIDR block
#   - Attaches an Internet Gateway to the VPC
#   - Uses an S3 backend to store the Terraform state file
#
# Author      : Azizbek Imamkulov
# Environment : Development
# Region      : us-east-1
# Backend     : S3 (azizbek-imamkulov-terraform-state)
#
# Outputs:
#   - VPC ID
#   - VPC CIDR block
############################################################


provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "azizbek-imamkulov-terraform-state"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "My VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

#--------------------------------------------------------------------

output "vpc_id" {
  value = aws_vpc.main.id
}


output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
