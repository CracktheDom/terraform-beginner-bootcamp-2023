# variable "user-uuid" {
#   description = "Unique identifier for a user"
#   type        = string

#   validation {
#     condition     = can(regex("^([a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12})$", var.user-uuid))
#     error_message = "The user-uuid must be a valid UUID." 
#   }
# }