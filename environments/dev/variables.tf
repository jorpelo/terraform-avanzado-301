variable "project" {
  type        = string
  description = "Nombre corto del proyecto"
}

variable "environment" {
  type        = string
  description = "Entorno: dev, test o prod"
}

variable "aws_region" {
  type        = string
  description = "Región de AWS de referencia"
  default     = "us-east-2"
}

variable "lab_user" {
  type        = string
  description = "Identificador del alumno (prefijo curso-<usuario>-*)"
}
