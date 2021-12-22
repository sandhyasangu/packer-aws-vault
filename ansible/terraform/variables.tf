variable "okta_base_url" {
  default     = "okta.com"
  description = "The vendor provided base url"
}

variable "okta_org" {
  default = "gastro"
}

variable "okta_token" {
  description = "A token that allows vault to read groups from the okta org"
}

variable "okta_admin_groups" {
  type    = list(string)
  default = []
}