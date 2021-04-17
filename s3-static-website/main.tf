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
