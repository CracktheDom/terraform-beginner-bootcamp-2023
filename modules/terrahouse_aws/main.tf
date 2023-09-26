
# Generate a random string
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
resource "random_string" "random_bucket_name" {
  length  = 26
  special = false
  upper   = false

    # S3 bucket validation
  validation {
    # Bucket name must be between 3 and 63 characters long
    condition     = length(random_string.random_bucket_name.result) > 2 && length(random_string.random_bucket_name.result) < 64
    error_message = "Bucket name must be between 3 and 63 characters."
  }
  
  # Bucket name can contain only lowercase letters, numbers, periods, and dashes
  validation {
    condition     = can(regex("^[a-z0-9.-]*$", random_string.random_bucket_name.result))
    error_message = "Bucket name can only contain lowercase letters, numbers, periods, and dashes."
  }

  # Bucket name must not start or end with period or dash
  validation {
    condition     = !can(regex("^[-.]|[-.]$", random_string.random_bucket_name.result)) 
    error_message = "Bucket name must not start or end with a period or dash."
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "wonder_bucket" {
  bucket = random_string.random_bucket_name.result
  
  tags = {
    UserUuid = var.user-uuid
  }

  # Other resource configuration...
}

/* Notice that there is no provider block in this configuration. 
When Terraform processes a module block, it will inherit the provider from the 
enclosing configuration. Because of this, we recommend that you do not include 
provider blocks in modules.

https://developer.hashicorp.com/terraform/tutorials/modules/module-create
*/