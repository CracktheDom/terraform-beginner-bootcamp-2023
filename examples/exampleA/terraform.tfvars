// Here is an example terraform.tfvars file that defines variable values:

# AWS provider settings
aws_region = "us-east-1"

# EC2 instance settings
instance_type = "t2.micro"
instance_name = "my-server"

# Auto scaling group settings
min_size = 1
max_size = 3

# Database settings
db_engine = "mysql" 
db_name = "myapp"
db_username = "admin"
db_password = "abcdef123456" 

# Application settings
app_name = "My App"
app_port = 8080

# List of security groups
security_groups = ["sg-123", "sg-456"]

# Map of tags 
tags = {
  "Env" = "dev"
  "Team" = "devops"
}

Simple values like strings, numbers, and booleans are used for primitive types. Lists and maps allow customizing groups of values.

The .tfvars file allows overriding defaults without changing the base Terraform code. This provides flexibility to adapt the infrastructure across environments.
