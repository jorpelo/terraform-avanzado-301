terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "naming" {
  source      = "../../modules/naming"
  project     = var.project
  environment = var.environment
}

module "tags" {
  source      = "../../modules/tagging"
  project     = var.project
  environment = var.environment
}

module "bucket" {
  source      = "../../modules/s3"
  bucket_name = "curso-${var.lab_user}-data-${var.aws_region}"
  tags        = module.tags.tags
}

output "name_prefix" { value = module.naming.prefix }
output "common_tags" { value = module.tags.tags }
output "bucket_id" { value = module.bucket.bucket_id }
