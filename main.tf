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
  endpoint  = "http://localhost:4567/api"
  user_uuid = "e328f4ab-b99f-421c-84c9-4ccea042c7d1"
  token     = "9b49b3fb-b8e9-483c-b703-97ba88eef8e0"
}

# module "terrahouse_aws" {
#   source              = "./modules/terrahouse_aws"
#   index_html_filepath = var.index_html_filepath
#   error_html_filepath = var.error_html_filepath
#   content_version = var.content_version
#   # assets_path = var.assets_path
# }

resource "terratowns_home" "home" {
  name = "Fifty Years of Rap"
  description = <<EOF
2023 marked the 50th anniversary of the birth of Rap music!!!

It started with a back-to-school party in the Bronx, New York in 1973.
EOF

  domain_name = "57rfeknld.cloudfront.net"  # module.terrahouse_aws.cloudfront_domain
  town = "Ripping-Rap-Ridge"  # make sure to choose a town that is already in the list in the mock server
  content_version = var.content_version
}
