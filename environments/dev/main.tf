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
  source      = "git::https://github.com/jorpelo/terraform-avanzado-301.git//modules/s3?ref=v1.0.0"
  bucket_name = "${var.project}-${var.environment}-data"
  tags        = { ManagedBy = "terraform" }
}

output "bucket_id" { value = module.bucket.bucket_id }