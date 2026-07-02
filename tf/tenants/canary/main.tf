terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

provider "kubernetes" {
  host                   = "https://kubernetes.default.svc"
  token                  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
  cluster_ca_certificate = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
}

# The module ref IS the version pin. Kargo's hcl-update bumps ?ref=... here.
module "podinfo" {
  source    = "git::https://github.com/himeshpanc/tf-podinfo-module.git//?ref=6.19.0"
  namespace = "tf-canary"
}
