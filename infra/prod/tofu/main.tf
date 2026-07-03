# Pattern A PROD — tofu provisions the greeting in OpenBao at an ISOLATED prod
# path (secret/infra-prod). Talks to OpenBao only (VAULT_ADDR/VAULT_TOKEN), never
# the K8s API. Vault KV writes are idempotent → no state backend needed.
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
  path     = "infra-prod-${var.module_version}"
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
