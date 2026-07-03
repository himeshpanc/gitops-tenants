terraform {
  # State lives in a Secret in-cluster. host/token/CA come from KUBE_* env,
  # which the promotion step sets from the `tf-kube` Kargo secret (the promotion
  # pod does not mount a SA token, so we supply an explicit scoped token).
  backend "kubernetes" {
    secret_suffix = "tenant-canary"
    namespace     = "kargo-tf-state"
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# Auth via KUBE_HOST / KUBE_TOKEN / KUBE_CLUSTER_CA_CERT_DATA env (set by the step).
provider "kubernetes" {}

# The module ref IS the version pin. Kargo's hcl-update bumps ?ref=... here.
module "podinfo" {
  source    = "git::https://github.com/himeshpanc/tf-podinfo-module.git//?ref=6.19.0"
  namespace = "tf-canary"
}
