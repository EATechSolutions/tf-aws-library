variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "environment" {
  type        = string
  description = "Environment"
}

# mfa
variable "mfa_configuration" {
  default = "OFF"
  description = "Whether to enable MFA for the user pool"
}

# password variables
variable "password_length" {
  default = 8
}

variable "password_lowercase" {
  default = true
}

variable "password_uppercase" {
  default = true
}

variable "password_numbers" {
  default = true
}

variable "password_symbols" {
  default = true
}

variable "temp_password_validity" {
  default = 7
}

# verification
variable "verification_method" {
  default = "CONFIRM_WITH_LINK"
  # work needs to be done to use with code (Prefer with link)
  description = "Can be either CONFIRM_WITH_LINK or CONFIRM_WITH_CODE"
}

variable "verify_message" {
  default = "Please click the link below to verify your email address. {##Verify Email##} "
}

variable "verrify_subject" {
  default = "Your verification link"
}

# # email configuration
# variable "from_email" {
#   description = "John Doe <johndoe@email.com> OR john.doe@email.com OR \"John B. Doe\" <john.b.doe@email.com>"
# }

# variable "reply_email" {
#   description = "john@email.com"
# }

# variable "email_sns" {
#   description = "ARN of the SES verified email identity to to use"
# }

# user pool client
variable "refresh_token_validity" {
  default = 30
}