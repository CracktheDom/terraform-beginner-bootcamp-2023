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
