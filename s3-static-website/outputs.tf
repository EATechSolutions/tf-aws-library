output "bucket" {
  value = aws_s3_bucket.website.id
}

output "bucket_endpoint" {
  value = aws_s3_bucket.website.website_endpoint
}