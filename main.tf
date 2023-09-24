terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "random" {
  # Configuration options
}

# Generate a random string 
resource "random_string" "random_bucket_name" {
  length  = 16
  special = false
}

# Output the generated random string
output "random_bucket_name_string" {
    value = random_string.random_bucket_name.result
}
