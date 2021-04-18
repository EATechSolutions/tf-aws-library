locals {
  origin_id = "${var.application_name}-${var.environment}-${var.origin_endpoint}"
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
    target_origin_id       = local.origin_id

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
    acm_certificate_arn = var.certificate_arn
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
