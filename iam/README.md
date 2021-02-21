# Terraform AWS IAM module

## About:

Basic AWS IAM role and policy module that expects 2 json files (see directory: ```./lambda-policy-example/```):

1) **Assume role policy**, defines the principle service actor. In the example that is Lambda.
2) **Access policy**, defines the policies that determine which services the assumed role has access to.


## How to use:

You can copy the example files in the local module policies directory. To set up variables you can use the ```role_vars``` parameter to pass thm along to the json policy file.

```terraform
module "iam" {
  source = "git::https://github.com/EATechSolutions/tf-aws-library.git//iam"

  application_name    = var.application_name
  environment         = var.environment
  region              = var.region

  assume_role_policy = file("${path.module}/policies/lambda-assume-role.json")
  template           = file("${path.module}/policies/lambda.json")
  role_name          = "${local.lambda_function_name}-role"
  policy_name        = "${local.lambda_function_name}-policy"

  role_vars = {
    cognito_user_pool_arn = var.cognito_user_pool_arn
  }
}
```

## Changelog

### v1.0
 - Initial release