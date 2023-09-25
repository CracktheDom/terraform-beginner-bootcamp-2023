terraform {
  cloud {
    organization = "cloudBouncer"
    workspaces {
      name = "terra-house-1"
    }
  }
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

provider "random" {
  # Configuration options
}

# Generate a random string
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
resource "random_string" "random_bucket_name" {
  length  = 26
  special = false
  upper   = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "wonder_bucket" {
  bucket = random_string.random_bucket_name.result

}

# Output the generated random string
output "random_bucket_name_string" {
  value = random_string.random_bucket_name.result
}
