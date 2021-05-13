locals {
  user_pool_name = "${var.application_name}-${var.environment}-user_pool"
  user_pool_client_web_name = "${var.application_name}-${var.environment}-user_pool_client_web"
  # user_pool_client_name = "${var.application_name}-${var.environment}-user_pool_client"
  user_pool_domain = "${var.application_name}-${var.environment}"
  identity_pool_name = "${var.application_name}-${var.environment}-identity_pool"
  authenticated_role_name = "${var.application_name}-${var.environment}-authenticated_role"
  authenticated_role_policy_name = "${var.application_name}-${var.environment}-authenticated_role_policy"
  unauthenticated_role_name = "${var.application_name}-${var.environment}-unauthenticated_role"
  unauthenticated_role_policy_name = "${var.application_name}-${var.environment}-unauthenticated_role_policy"
}

resource "aws_cognito_user_pool" "user_pool" {
  name = local.user_pool_name

  schema {
    name = "email"
    attribute_data_type = "String"
    required = true
    mutable = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name = "name"
    attribute_data_type = "String"
    required = true
    mutable = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration = var.mfa_configuration

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length = var.password_length
    require_lowercase = var.password_lowercase
    require_uppercase = var.password_uppercase
    require_numbers = var.password_numbers
    require_symbols = var.password_symbols
    temporary_password_validity_days = var.temp_password_validity
  }

  verification_message_template {
    default_email_option = var.verification_method
    email_subject_by_link = var.verrify_subject
    email_message_by_link = var.verify_message
  }

  # email_configuration {
  #   email_sending_account = "DEVELOPER"
  #   from_email_address = var.from_email
  #   reply_to_email_address = var.reply_email
  #   source_arn = var.email_sns
  # }

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
  }

  lifecycle {
    ignore_changes = [schema]
  }
}


# user pool client web
resource "aws_cognito_user_pool_client" "client_web" {
  name = local.user_pool_client_web_name
  refresh_token_validity = var.refresh_token_validity
  user_pool_id = aws_cognito_user_pool.user_pool.id
}
  
  # allowed_oauth_flows = ["code"]
  # allowed_oauth_flows_user_pool_client = true
  # allowed_oauth_scopes = [
  #   "email",
  #   "openid",
  #   "profile",
  #   "aws.cognito.signin.user.admin"
  # ]
  # callback_urls = var.callback_urls
  # logout_urls = var.logout_urls
  # default_redirect_uri = var.default_redirect_uri
  # supported_identity_providers = [
  #   "COGNITO",
  #   "Google",
  #   "Facebook"
  # ]

  # depends_on = [
  #   aws_cognito_identity_provider.facebook,
  #   aws_cognito_identity_provider.google
  # ]
# }

# # user pool client
# resource "aws_cognito_user_pool_client" "client" {
#   name = local.user_pool_client_name
#   refresh_token_validity = 30
#   user_pool_id = aws_cognito_user_pool.user_pool.id
#   generate_secret = true

#   allowed_oauth_flows = ["code"]
#   allowed_oauth_flows_user_pool_client = true
#   allowed_oauth_scopes = [
#     "email",
#     "openid",
#     "profile",
#     "aws.cognito.signin.user.admin"
#   ]
#   callback_urls = var.callback_urls
#   default_redirect_uri = var.default_redirect_uri
#   logout_urls = var.logout_urls
#   supported_identity_providers = [
#     "COGNITO",
#     "Google",
#     "Facebook"
#   ]

#   depends_on = [
#     aws_cognito_identity_provider.facebook,
#     aws_cognito_identity_provider.google
#   ]
# }

# hosted UI settings
resource "aws_cognito_user_pool_domain" "main" {
  domain = local.user_pool_domain
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

# # Facebook identity provider
# resource "aws_cognito_identity_provider" "facebook" {
#   user_pool_id = aws_cognito_user_pool.user_pool.id
#   provider_name = "Facebook"
#   provider_type = "Facebook"

#   provider_details = {
#     client_id = var.facebook_client_id
#     client_secret = var.facebook_client_secret
#     authorize_scopes = "email,public_profile"
#   }

#   attribute_mapping = {
#     email = "email"
#     name = "name"
#     username = "id"
#   }
# }

# # Google identity provider
# resource "aws_cognito_identity_provider" "google" {
#   user_pool_id = aws_cognito_user_pool.user_pool.id
#   provider_name = "Google"
#   provider_type = "Google"

#   provider_details = {
#     client_id = var.google_client_id
#     client_secret = var.google_client_secret
#     authorize_scopes = "openid email profile"
#   }

#   attribute_mapping = {
#     email = "email"
#     name = "name"
#     username = "sub"
#   }
# }





resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = local.identity_pool_name
  allow_unauthenticated_identities = false

  # cognito_identity_providers {
  #   client_id = aws_cognito_user_pool_client.client.id
  #   provider_name = aws_cognito_user_pool.user_pool.endpoint
  # }

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.client_web.id
    provider_name = aws_cognito_user_pool.user_pool.endpoint
  }
}

resource "aws_iam_role" "authenticated" {
  name = local.authenticated_role_name

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "authenticated"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = local.authenticated_role_policy_name
  role = aws_iam_role.authenticated.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "unauthenticated" {
  name = local.unauthenticated_role_name

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "unauthenticated"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "unauthenticated" {
  name = local.unauthenticated_role_policy_name
  role = aws_iam_role.unauthenticated.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "mobileanalytics:PutEvents",
          "cognito-sync:*"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  }
  EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "roles_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}