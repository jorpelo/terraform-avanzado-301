variable "project"     { type = string }
variable "environment" { type = string }

variable "extra_tags" {
  type    = map(string)
  default = {}
}

output "tags" {
  value = merge({
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }, var.extra_tags)
}