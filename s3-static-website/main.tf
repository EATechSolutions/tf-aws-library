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
  length = 6
  number = false
  upper = false
  special = false
  lower = true
}

# ----------------------------------
# Resource: Website Bucket
# ----------------------------------
resource "aws_s3_bucket" "website" {
  bucket = "${var.application_name}.${var.environment}.website.${random_string.postfix.result}"
  acl = "public-read"
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