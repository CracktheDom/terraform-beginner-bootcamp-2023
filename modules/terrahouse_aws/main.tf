# Generate a random string
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
resource "random_string" "random_bucket_name" {
  length  = 26
  special = false
  upper   = false
}

resource "random_uuid" "id" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "wonder_bucket" {
  bucket = random_string.random_bucket_name.result

  tags = {
    UserUuid = random_uuid.id.result
  }

  # Other resource configuration...
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
resource "aws_s3_bucket_website_configuration" "wonder_bucket_config" {
  bucket = aws_s3_bucket.wonder_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html#bucket-policy-static-site
resource "aws_s3_bucket_policy" "wonder_bucket_policy" {
  bucket = aws_s3_bucket.wonder_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.wonder_bucket.arn,
          "${aws_s3_bucket.wonder_bucket.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "wonder_ownership_controls" {
  bucket = aws_s3_bucket.wonder_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html
resource "aws_s3_bucket_public_access_block" "wonder_public_access" {
  bucket = aws_s3_bucket.wonder_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "wonder_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.wonder_ownership_controls,
    aws_s3_bucket_public_access_block.wonder_public_access,
  ]

  bucket = aws_s3_bucket.wonder_bucket.id
  acl    = "public-read"
}

/* Notice that there is no provider block in this configuration. 
When Terraform processes a module block, it will inherit the provider from the 
enclosing configuration. Because of this, we recommend that you do not include 
provider blocks in modules.

https://developer.hashicorp.com/terraform/tutorials/modules/module-create
*/