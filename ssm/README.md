# Terraform SSM Module

## About:

This Terraform module creates Systems Manager Parameters and uses standard prefixes ``environment`` and ``application_name`` for your parameters.

For instance:
``/example/env/cognito_user_pool_arn``

## How to use:

```terraform
module "ssm_parameters" {
  source = "git::https://github.com/EATechSolutions/tf-aws-library.git//ssm"

  application_name = "example"
  environment      = "dev"

  parameters = {
    "cognito_user_pool_arn" = {
      "type"  = "String"
      "value" = module.cognito.cognito_user_pool_arn
    },
    "cognito_user_pool_client_id" = {
      "type"  = "String"
      "value" = module.cognito.cognito_user_pool_client_id
    },
    "cognito_identity_pool_id" = {
      "type"  = "String"
      "value" = module.cognito.cognito_identity_pool_id
    }
  }
}
```