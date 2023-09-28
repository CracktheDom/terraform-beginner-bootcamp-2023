# Generate a random string
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
resource "random_string" "random_bucket_name" {
  length  = 26
  special = false
  upper   = false
}

resource "random_uuid" "id" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}


/* Notice that there is no provider block in this configuration. 
When Terraform processes a module block, it will inherit the provider from the 
enclosing configuration. Because of this, we recommend that you do not include 
provider blocks in modules.

https://developer.hashicorp.com/terraform/tutorials/modules/module-create
*/
