locals {
  domain    = var.environment == "prod" ? var.domain : "${var.environment}.${var.domain}"
}

# ----------------------------------
# Resource: Certificate Manager
# ----------------------------------
resource "aws_acm_certificate" "cert" {
  provider = aws.acm

  domain_name               = local.domain
  subject_alternative_names = ["*.${local.domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.acm

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_dns_records : record.fqdn]
}

resource "aws_route53_record" "cert_dns_records" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_hosted_zone_id
}
