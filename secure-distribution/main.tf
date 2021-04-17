locals {
  origin_id = "${var.application_name}-${var.environment}-${origin_endpoint}"
  domain    = var.environment == "prod" ? var.domain : "${var.environment}.${var.domain}"
}

# ----------------------------------
# Resource: Cloudfront
# ----------------------------------
resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name = var.origin_endpoint
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  aliases         = [local.domain]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

# ----------------------------------
# Resource: Route 53
# ----------------------------------
resource "aws_route53_record" "www" {
  zone_id = var.route53_hosted_zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

# ----------------------------------
# Resource: Certificate Manager
# ----------------------------------
resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain
  subject_alternative_names = var.environment == "prod" ? ["www.${local.domain}"] : []
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  # validation_record_fqdns = [for record in aws_route53_record.cert_dns_records : record.fqdn]
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
