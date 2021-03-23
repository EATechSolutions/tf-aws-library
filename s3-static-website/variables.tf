variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "bucket_name" {
  type        = string
  description = "if you know the bucket name"
  default     = ""
}

variable "domain" {
  type        = string
  description = "If specified it creates a cloudfront distribution with route 53 record"
  default     = ""
}

variable "ssl_certificate" {
  type        = string
  description = "Certificate manager created cerificate ARN"
}