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
      source  = "local.providers/local/terratowns"
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
  endpoint  = "https://terratowns.cloud/api"
  user_uuid = var.terratowns_uuid
  token     = var.terratowns_access_token
}

module "terrahouse_aws" {
  source              = "./modules/terrahouse_aws"
  index_html_filepath = "${path.root}/public/index.html"
  error_html_filepath = "${path.root}/public/error.html"
  content_version     = var.content_version
  # assets_path         = var.assets_path
  # uuid                = var.terratowns_uuid
}

resource "terratowns_home" "home" {
  name        = "Fifty Years of Rap"
  description = <<EOF
2023 marked the 50th anniversary of the birth of Rap music!!!

It started with a back-to-school party in the Bronx, New York in 1973.
EOF

  domain_name     = module.terrahouse_aws.cloudfront_domain
  town            = "missingo"  # make sure to choose a town that is already in the list in the mock server
  content_version = var.content_version
}
