variable "index_html_filepath" {
  type = string
}

variable "error_html_filepath" {
  type = string
}

variable "content_version" {
  type = number
}

variable "terratowns_access_token" {
  type = string
}

variable "terratowns_uuid" {
  type = string
}

variable "which_terratown" {
  type = list(string)
  description = "list of available towns in TerraTown"
  default = [ "melomaniac-mansion", "the-nomad-pad", "video-valley", "cooker-cove", "gamers-grotto", "missingo" ]
  validation {
        condition = contains(["melomaniac-mansion", "the-nomad-pad", "video-valley", "cooker-cove", "gamers-grotto", "missingo"], var.which_terratown[0])
        error_message = "You must a town within the list of towns"
  }
}