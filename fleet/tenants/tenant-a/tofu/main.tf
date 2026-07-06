# FLEET tenant (tenant-a) — tofu provisions a versioned tenant PLATFORM CONFIG bundle in
# OpenBao (a realistic multi-field config). The ExternalSecret is repointed to
# secret/tenant-a-<version> via yaml-update. tofu talks only to OpenBao.
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
  # replicas scale with the module MINOR version, so a version bump visibly
  # rescales the fleet (1.2.0 -> 2 pods, 1.3.0 -> 3 pods, ...).
  ver_minor = try(split(".", var.module_version)[1], "1")
  # Realistic tenant platform config bundle.
  bundle = {
    app_version   = var.module_version
    replicas      = local.ver_minor
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

# Non-sensitive outputs so the config bundle is VISIBLE in the plan's
# "Changes to Outputs" section inside each promotion PR (the KV data_json itself
# is marked sensitive by the vault provider, so these outputs surface the values).
output "secret_path"   { value = local.path }
output "app_version"   { value = local.bundle.app_version }
output "replicas"      { value = tonumber(local.ver_minor) }
output "ingress_host"  { value = local.bundle.ingress_host }
output "feature_flags" { value = local.bundle.feature_flags }
