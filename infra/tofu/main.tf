# Pattern A: tofu provisions a NON-Kubernetes system (OpenBao) and emits an output.
# It talks to OpenBao's API (VAULT_ADDR + VAULT_TOKEN) — NOT the Kubernetes API,
# so it needs NO cluster creds / kubeconfig. Vault KV writes are idempotent, so
# no state backend is needed (ephemeral local state is harmless).
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0, < 5.0"
    }
  }
}

# Auth via VAULT_ADDR + VAULT_TOKEN env (set by the promotion step from the
# openbao-creds Kargo secret).
provider "vault" {}

variable "module_version" {
  type    = string
  default = "unknown"
}

locals {
  greeting = "greetings from tofu-provisioned OpenBao (module ${var.module_version})"
}

# "Provision" the greeting in OpenBao at an ISOLATED path (its own key, so it
# never collides with the shared tenant-config used by the other tracks).
resource "vault_kv_secret_v2" "greeting" {
  mount     = "secret"
  name      = "infra-demo"
  data_json = jsonencode({ greeting = local.greeting })
}

# The output that flows into GitOps via yaml-update (Pattern A: tf-output → git).
output "greeting" {
  value = local.greeting
}
