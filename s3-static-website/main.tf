locals {
  bucket_name  = var.bucket_name != "" ? var.bucket_name : "${var.application_name}.${var.environment}.website.${random_string.postfix.result}"
  s3_origin_id = "${var.application_name}-${var.environment}-s3-origin"
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
# Resource: Cloudformation
# ----------------------------------
resource "aws_cloudfront_distribution" "cloudfront" {
  count = var.domain == "" ? 0 : 1

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
  aliases         = [var.domain, "www.${var.domain}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = local.s3_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.ssl_certificate
    ssl_support_method  = "sni-only"
  }
}