provider "http" {
  # Configuration options
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "multinodes"
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "multinodes"
}

data "kubernetes_secret" "argocd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [
    kubectl_manifest.argocd
  ]
}
provider "argocd" {
  server_addr                 = "port-forward"
  username                    = "admin"
  password                    = data.kubernetes_secret.argocd.data.password
  port_forward                = true
  port_forward_with_namespace = "argocd"
  insecure                    = true
  grpc_web                    = true
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "multinodes"
  }
}