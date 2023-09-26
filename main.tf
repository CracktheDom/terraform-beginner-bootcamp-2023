terraform {
  required_providers {

    # https://registry.terraform.io/providers/hashicorp/random/latest/docs
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
}

module "terrahouse_aws" {
  source = "./modules/terrahouse_aws"
  user_uuid = var.user-uuid
  bucket_name = random_string.random_bucket_name.result
}
