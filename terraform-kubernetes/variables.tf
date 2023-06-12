variable "main_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "region" {
  default = "us-east-2"
}

variable "registry_server" {
  type      = string
  sensitive = true
}

variable "registry_username" {
  type      = string
  sensitive = true
}

variable "registry_password" {
  type      = string
  sensitive = true
}

variable "registry_email" {
  type      = string
  sensitive = true
}

variable "namespace" {
  type    = string
  default = "django-namespace"
}

variable "registry_password_ecr" {
  type      = string
  sensitive = true
}