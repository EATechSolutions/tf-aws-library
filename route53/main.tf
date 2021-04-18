locals {
  origin_id = "${var.application_name}-${var.environment}-${var.origin_endpoint}"
  domain    = var.environment == "prod" ? var.domain : "${var.environment}.${var.domain}"
}

# ----------------------------------
# Resource: Route 53
# ----------------------------------
resource "aws_route53_record" "www" {
  zone_id = var.route53_hosted_zone_id
  name    = "${var.subdomain}.${local.domain}"
  type    = "A"

  records = [var.origin_endpoint]
  # alias {
  #   name                   = var.api_endpoint
  #   zone_id                = var.route53_hosted_zone_id
  #   evaluate_target_health = false
  # }
}
