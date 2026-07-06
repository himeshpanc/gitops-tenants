# FLEET tenant (tenant-a) — tofu provisions a versioned tenant PLATFORM CONFIG bundle in
# OpenBao (a realistic multi-field config, not just a greeting). The ExternalSecret
# is repointed to secret/tenant-a-<version> via yaml-update. tofu talks only to OpenBao.
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
  path = "tenant-a-${var.module_version}"
  # Realistic tenant platform config bundle (shown in the tf-plan / PR).
  bundle = {
    app_version   = var.module_version
    replicas      = "2"
    ingress_host  = "tenant-a.demo.local"
    feature_flags = "ui=on,cache=on"
    # Composed display value podinfo serves (via ESO).
    greeting      = "platform v${var.module_version} — tenant-a (flags: ui=on,cache=on)"
  }
}

resource "vault_kv_secret_v2" "platform" {
  mount     = "secret"
  name      = local.path
  data_json = jsonencode(local.bundle)
}

output "secret_path" {
  value = local.path
}
