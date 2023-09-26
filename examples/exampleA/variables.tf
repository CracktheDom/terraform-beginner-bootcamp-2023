// Here are some examples of declaring variables in Terraform:

# Simple string variable
variable "instance_name" {
  type = string
  default = "my-server"
}

# Number variable 
variable "instance_count" {
  type = number
  default = 1
}

# Boolean flag
variable "enable_monitoring" {
  type = bool
  default = true
}

# List of strings
variable "security_groups" {
  type = list(string)
  default = ["sg-123", "sg-456"]
}

# Map of strings
variable "tags" {
  type = map(string)
  default = {
    "Name" = "my-server"
    "Env" = "dev"
  }
}

# Object variable
variable "instance" {
  type = object({
    type = string
    size = string
  })
  default = {
    type = "t2.micro"
    size = "Small" 
  }
}

# Tuple 
variable "cidrs" {
  type = tuple([string, number, bool])
  default = ["10.0.0.0/16", 8, true]
}
