variable "project"     { type = string }
variable "environment" { type = string }

output "prefix" {
  value = "${var.project}-${var.environment}"
}