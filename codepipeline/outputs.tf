output "badge_url" {
  description = "The URL of the build badge when badge_enabled is enabled"
  value       = aws_codebuild_project._.badge_url
}

# output "connection" {
#   description = "The codestar connection to Github"
#   value       = aws_codestarconnections_connection._.connection_status
# }

output "s3_bucket_name" {
  description = "The Artifact bucket name"
  value       = aws_s3_bucket.artifact_store.bucket
}