locals {
  bucket_name  = var.bucket_name != "" ? var.bucket_name : "${var.application_name}.${var.environment}.website.${random_string.postfix.result}"
  s3_origin_id = "${var.application_name}-${var.environment}-s3-origin"
  domain       = var.environment == "prod" || var.domain == "" ? var.domain : "${var.environment}.${var.domain}"
}

data "template_file" "_" {
  template = file("${path.module}/policies/website-policy.json")
  vars = {
    s3_bucket_arn = aws_s3_bucket.website.arn
  }
}

# ----------------------------------
# Resource: Random string
# ----------------------------------
resource "random_string" "postfix" {
  length  = 6
  number  = false
  upper   = false
  special = false
  lower   = true
}

# ----------------------------------
# Resource: Website Bucket
# ----------------------------------
resource "aws_s3_bucket" "website" {
  bucket        = local.bucket_name
  acl           = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "_" {
  bucket = aws_s3_bucket.website.id
  policy = data.template_file._.rendered
}

# ----------------------------------
# Resource: Cloudfront
# ----------------------------------
resource "aws_cloudfront_distribution" "cloudfront" {
  count = local.domain == "" ? 0 : 1

  origin {
    domain_name = aws_s3_bucket.website.website_endpoint
    origin_id   = local.s3_origin_id

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
  count = var.route53_hosted_zone_id == "" || local.domain == "" ? 0 : 1

  zone_id = var.route53_hosted_zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront[0].domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# ----------------------------------
# Resource: Certificate Manager
# ----------------------------------
resource "aws_acm_certificate" "cert" {
  count = local.domain == "" ? 0 : 1

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
