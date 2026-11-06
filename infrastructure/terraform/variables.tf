variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "aws-static-website"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "production"
}
