terraform {
  # State lives in a Secret in-cluster. host/token/CA come from KUBE_* env,
  # which the promotion step sets from the `tf-kube` Kargo secret (the promotion
  # pod does not mount a SA token, so we supply an explicit scoped token).
  backend "kubernetes" {
    secret_suffix = "tenant-canary"
    namespace     = "kargo-tf-state"
    config_path   = "kubeconfig"
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# Same kubeconfig as the backend; token comes from $KUBE_TOKEN at runtime.
provider "kubernetes" {
  config_path = "kubeconfig"
}

# The module ref IS the version pin. Kargo's hcl-update bumps ?ref=... here.
module "podinfo" {
  source    = "git::https://github.com/himeshpanc/tf-podinfo-module.git//?ref=6.25.0"
  namespace = "tf-canary"
}
