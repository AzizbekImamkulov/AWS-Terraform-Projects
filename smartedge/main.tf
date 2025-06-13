provider "aws" {
  region = var.aws_region
}

module "iot_infra" {
  source       = "./modules/iot"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}
