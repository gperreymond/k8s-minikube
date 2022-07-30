# -----------------------------------------------------
# INSTALL MONGO WEBUI
# -----------------------------------------------------

resource "kubernetes_namespace" "mongo-webui" {
  metadata {
    name = "mongo-webui"
  }
}

resource "argocd_application" "mongo-webui" {
  metadata {
    name      = "mongo-webui"
    namespace = "argocd"
  }

  wait = false

  spec {
    source {
      repo_url        = "https://github.com/gperreymond/k8s-minikube"
      path            = "charts/mongo-webui"
      target_revision = "main"
    }

    sync_policy {
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = false
      }
      retry {
        limit = "5"
        backoff = {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "istio-system"
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_namespace.mongo-webui
  ]
}