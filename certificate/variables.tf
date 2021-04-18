variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "domain" {
  type        = string
  description = "If specified it creates a cloudfront distribution with route 53 record"
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "Zone ID of the Route 53 hosted zone"
}
