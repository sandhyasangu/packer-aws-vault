terraform {
  backend "s3" {}
}

resource "vault_audit" "audit_file" {
  type = "file"

  options = {
    file_path = "/var/log/vault-audit.log"
  }
}

resource "vault_okta_auth_backend" "okta" {
  description  = "Terraform Okta auth backend"
  base_url     = var.okta_base_url
  organization = var.okta_org
  token        = var.okta_token
}

resource "vault_okta_auth_backend_group" "adminteams" {
  count      = length(var.okta_admin_groups)
  path       = vault_okta_auth_backend.okta.path
  group_name = var.okta_admin_groups[count.index]
  policies   = [vault_policy.admin.name]
}