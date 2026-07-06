# Pattern A (demo) — tofu provisions the greeting in OpenBao at a VERSIONED path
# (secret/tenant-a-<version>). The ExternalSecret is repointed to this path via
# yaml-update, so "which version the app serves" is a git-controlled decision.
# tofu talks only to OpenBao (VAULT_ADDR/VAULT_TOKEN) — no cluster creds.
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0, < 5.0"
    }
  }
}

provider "vault" {}

variable "module_version" {
  type    = string
  default = "unknown"
}

locals {
  path     = "tenant-a-${var.module_version}"
  greeting = "greetings from tofu-provisioned OpenBao (module ${var.module_version})"
}

resource "vault_kv_secret_v2" "greeting" {
  mount     = "secret"
  name      = local.path
  data_json = jsonencode({ greeting = local.greeting })
}

# The versioned path the ExternalSecret should point at (flows into git via yaml-update).
output "secret_path" {
  value = local.path
}
