variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "origin_endpoint" {
  type        = string
  description = "Endpoint to distribute"
}

variable "domain" {
  type        = string
  description = "If specified it creates a cloudfront distribution with route 53 record"
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "Zone ID of the Route 53 hosted zone"
}

variable "certificate_arn" {
  type        = string
  description = "The certificate arn created for this distribution"
}
