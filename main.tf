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

    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

provider "random" {}

provider "terratowns" {
  endpoint  = "http://localhost:4567"
  user_uuid = "d16ea99b-60ea-4ddc-8414-3b8a3ab72e9f"
  token     = "9b49b3fb-b8e9-483c-b703-97ba88eef8e0"
}

# module "terrahouse_aws" {
#   source              = "./modules/terrahouse_aws"
#   index_html_filepath = var.index_html_filepath
#   error_html_filepath = var.error_html_filepath
#   content_version = var.content_version
#   # assets_path = var.assets_path
# }
