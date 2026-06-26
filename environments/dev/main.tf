provider "aws" {
  region = var.aws_region
  profile = "lab"
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

output "name_prefix" { value = module.naming.prefix }
output "common_tags" { value = module.tags.tags }

module "bucket" {
  source      = "../../modules/s3"
  bucket_name = "curso-${var.lab_user}-data-${var.aws_region}"
  tags        = module.tags.tags
}

output "bucket_id" { value = module.bucket.bucket_id }