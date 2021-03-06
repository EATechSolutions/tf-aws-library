# Terraform AWS CodePipeline for AWS SAM Applications

## About:

Deploys an AWS CodePipeline specifically designed for AWS SAM.

It requires these artifacts, amongst code obviously, in the source repository:
- AWS SAM template file (e.g. template.yaml), contains a description of your stack in CFL.
- CloudFormation Template configuration file (e.g. configuration.json), contains the parameter configuration you want to deploy your stack with. This is used during the CloudFormation Change Set, as part of the deployment stage.

## How to use:

This version of the module expects GitHub as source code repository to be used. You'll need an OAuthToken (``github_token``)  that has access to the repo (``github_repo``) you want to read from.

The ``stack_name`` is what you configured as a SAM stack name.

```hcl
data "template_file" "buildspec" {
  template = file("${path.module}/codebuild/buildspec.yml")
}

module "codepipeline" {
  source = "git::https://github.com/EATechSolutions/tf-aws-library.git//codepipeline"

  application_name    = var.application_name
  environment         = var.environment
  region              = var.region

  github_token        = var.github_token
  github_owner        = var.github_owner
  github_repo         = var.github_repo
  poll_source_changes = var.poll_source_changes

  build_image = "aws/codebuild/standard:4.0"
  buildspec   = data.template_file.buildspec.rendered

  stack_name = var.stack_name?

  parameter_overide_json = jsonencode({
    FromEmail = var.from_email
    ClientEmail = var.client_email
    CorsOrigin = var.cors_origin
    Region = var.region
  })

  environment_variable_map = [
    {
      name  = "REGION"
      value = var.region
      type  = "PLAINTEXT"
    },
    {
      name  = "COGNITO_USER_POOL_ID"
      value = module.cognito.cognito_user_pool_id
      type  = "PLAINTEXT"
    }
  ]
}
```

## Changelog

### V1.2
 - Added Environment variables support for CodeBuild templates.

### v1.1
 - Separated Buildspec YML file from module. See the ``./codebuild/buildspec.yml`` file for an example.

### v1.0
 - Initial release