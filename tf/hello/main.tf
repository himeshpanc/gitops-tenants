terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# In-cluster auth using the runner pod's mounted ServiceAccount token.
provider "kubernetes" {
  host                   = "https://kubernetes.default.svc"
  token                  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
  cluster_ca_certificate = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
}

# Trivial resource just to prove tofu-controller can plan+apply against the cluster.
resource "kubernetes_config_map" "hello" {
  metadata {
    name      = "tofu-hello"
    namespace = "default"
  }
  data = {
    message = "provisioned by tofu-controller via Flux"
  }
}

output "configmap_name" {
  value = kubernetes_config_map.hello.metadata[0].name
}
