variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "bucket_name" {
  type        = "string"
  description = "if you know the bucket name"
  default     = ""
}