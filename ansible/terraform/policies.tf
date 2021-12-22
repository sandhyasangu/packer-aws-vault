// policy from https://www.vaultproject.io/guides/identity/policies
data "vault_policy_document" "admin" {
  rule {
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Manage auth methods broadly across Vault"
  }

  rule {
    path         = "sys/auth/*"
    capabilities = ["create", "update", "delete", "sudo"]
    description  = "Create, update, and delete auth methods"
  }

  rule {
    path         = "sys/auth"
    capabilities = ["read"]
    description  = "List auth methods"
  }

  rule {
    path         = "sys/policy"
    capabilities = ["read"]
    description  = "List existing policies via CLI"
  }

  rule {
    path         = "sys/policy/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Create and manage ACL policies via CLI"
  }

  rule {
    path         = "sys/policies/acl/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Create and manage ACL policies via API"
  }

  rule {
    path         = "sys/capabilities"
    capabilities = ["create", "update"]
  }

  rule {
    path         = "sys/capabilities-self"
    capabilities = ["create", "update"]
  }

  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Manage secret engines broadly across Vault"
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read"]
    description  = "List existing secret engines"
  }

  rule {
    path         = "sys/health"
    capabilities = ["read", "sudo"]
    description  = "read health checks"
  }

  rule {
    path         = "sys/health"
    capabilities = ["read", "sudo"]
    description  = "read health checks"
  }

  rule {
    path         = "sys/audit"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "manage audit capabilities"
  }

  rule {
    path         = "sys/plugins/catalog/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Register a new plugin, or read/remove an existing plugin"
  }
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = data.vault_policy_document.admin.hcl
}
