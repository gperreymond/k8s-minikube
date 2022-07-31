# -----------------------------------------------------
# INSTALL MONGODB 01
# -----------------------------------------------------

resource "kubernetes_namespace" "mongodb-01" {
  metadata {
    name = "mongodb-01"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    kubectl_manifest.argocd
  ]
}

resource "argocd_application" "mongodb-01" {
  metadata {
    name      = "mongodb-01"
    namespace = "argocd"
  }

  wait = false

  spec {
    source {
      repo_url        = "https://github.com/gperreymond/k8s-minikube"
      path            = "charts/mongodb"
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
      namespace = "mongodb-01"
    }
  }

  depends_on = [
    kubernetes_namespace.mongodb-01
  ]
}

# -----------------------------------------------------
# INSTALL MONGODB 02
# -----------------------------------------------------

resource "kubernetes_namespace" "mongodb-02" {
  metadata {
    name = "mongodb-02"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    kubectl_manifest.argocd
  ]
}

resource "argocd_application" "mongodb-02" {
  metadata {
    name      = "mongodb-02"
    namespace = "argocd"
  }

  wait = false

  spec {
    source {
      repo_url        = "https://github.com/gperreymond/k8s-minikube"
      path            = "charts/mongodb"
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
      namespace = "mongodb-02"
    }
  }

  depends_on = [
    kubernetes_namespace.mongodb-02
  ]
}
