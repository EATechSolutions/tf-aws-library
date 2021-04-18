# Terraform S3 Static Website Module

## About:

This Terraform module creates a website backed by an s3 bucket. It standard prefixes ``environment`` and ``application_name`` for your bucket name.

For instance:
bucket name -> ``example.env.website.abcd12``
website -> ``http://example.dev.website.abcd12.s3-website.eu-west-2.amazonaws.com/``

## How to use:

```terraform
module "route53" {
  source                 = "git::https://github.com/EATechSolutions/tf-aws-library.git//route53"

  application_name       = "example"
  environment            = "dev"
  origin_endpoint        = "https://asjdaksdasjdasjd.asdaskdhiasud.com"
  domain                 = "nice-name.com"
  route53_hosted_zone_id = "asdasd.sadasd234234"
  subdomain              = "api"
}
```