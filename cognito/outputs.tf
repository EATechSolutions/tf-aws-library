output "unauthenticated_role_id" {
  value = aws_iam_role.unauthenticated.id
}

output "authenticated_role_id" {
  value = aws_iam_role.authenticated.id
}

output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client_web.id
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.identity_pool.id
}
