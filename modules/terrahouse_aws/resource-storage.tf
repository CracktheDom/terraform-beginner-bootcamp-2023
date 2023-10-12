# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "wonder_bucket" {
  bucket = "terraform-bootcamp-${random_string.random_bucket_name.result}"

  tags = {
    UserUuid = random_uuid.id.result
  }
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
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service : "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = [
          aws_s3_bucket.wonder_bucket.arn,
          "${aws_s3_bucket.wonder_bucket.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
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
# resource "aws_s3_bucket_public_access_block" "wonder_public_access" {
#   bucket = aws_s3_bucket.wonder_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_acl" "wonder_bucket_acl" {
#   depends_on = [
#     aws_s3_bucket_ownership_controls.wonder_ownership_controls,
#     aws_s3_bucket_public_access_block.wonder_public_access,
#   ]

#   bucket = aws_s3_bucket.wonder_bucket.id
#   acl    = "public-read"
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.wonder_bucket.id
  key    = "index.html"
  source = var.index_html_filepath

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("/path/to/file"))}"
  etag = filemd5(var.index_html_filepath)

  content_type = "text/html"
  lifecycle {
    ignore_changes = [ etag ]
    replace_triggered_by = [ terraform_data.content_version ]
  }
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.wonder_bucket.id
  key    = "error.html"
  source = var.error_html_filepath
  etag   = filemd5(var.error_html_filepath)
  content_type = "text/html"
  lifecycle {
    ignore_changes = [ etag ]
    replace_triggered_by = [ terraform_data.content_version ]
  }
}

resource "terraform_data" "content_version" {
  input = var.content_version
}

# # Create a local map to store file information
# locals {
#   asset_files = )
# }

# Iterate over each file in the assets directory
resource "aws_s3_object" "asset_objects" {
  for_each = fileset("${path.root}/public/assets/", "**/*.{jpg,jpeg}")
  bucket = aws_s3_bucket.wonder_bucket.id
  key = "assets/${each.key}"  # sets the key (object name) in the S3 bucket for each object
  source = "${path.root}/public/assets/${each.key}"  # Specifies the local file path for each object
  etag = filemd5("${path.root}/public/assets/${each.key}")
  content_type = "image/jpeg"
  lifecycle {
    ignore_changes = [ etag ]
  }
}

# # Example output to display the S3 object keys
# output "s3_object_keys" {
#   value = aws_s3_object.asset_objects[*].key
# }
