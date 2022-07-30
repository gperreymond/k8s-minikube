# -----------------------------------------------------
# INSTALL ISTIO
# -----------------------------------------------------

resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system"
  }
}

resource "argocd_project" "istio" {
  metadata {
    name      = "cluster-istio"
    namespace = "argocd"
  }

  spec {
    source_repos = ["*"]
    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }
    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "istio-system"
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_namespace.istio
  ]
}

resource "argocd_application" "istio-base" {
  metadata {
    name      = "cluster-istio-base"
    namespace = "argocd"
  }

  wait = false

  spec {
    project = "cluster-istio"
    source {
      repo_url        = "https://istio-release.storage.googleapis.com/charts"
      chart           = "base"
      target_revision = "1.14.2"
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

    ignore_difference {
      group         = "admissionregistration.k8s.io"
      kind          = "ValidatingWebhookConfiguration"
      json_pointers = ["/webhooks/0/failurePolicy"]
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "istio-system"
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_namespace.istio
  ]
}

resource "argocd_application" "istio_gateway" {
  metadata {
    name      = "cluster-istio-gateway"
    namespace = "argocd"
  }

  wait = false

  spec {
    project = "cluster-istio"
    source {
      repo_url        = "https://istio-release.storage.googleapis.com/charts"
      chart           = "gateway"
      target_revision = "1.14.2"
      helm {
        values = <<EOT
name: istio-ingressgateway
labels:
  app: istio-ingressgateway
  istio: ingressgateway
EOT
      }
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
    kubernetes_namespace.istio
  ]
}

resource "argocd_application" "istiod" {
  metadata {
    name      = "cluster-istio-istiod"
    namespace = "argocd"
  }

  wait = false

  spec {
    project = "cluster-istio"
    source {
      repo_url        = "https://istio-release.storage.googleapis.com/charts"
      chart           = "istiod"
      target_revision = "1.14.2"
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

    ignore_difference {
      group = "admissionregistration.k8s.io"
      kind  = "MutatingWebhookConfiguration"
      json_pointers = [
        "/webhooks/0/clientConfig/caBundle",
        "/webhooks/1/clientConfig/caBundle",
        "/webhooks/2/clientConfig/caBundle",
        "/webhooks/3/clientConfig/caBundle",
        "/webhooks/4/clientConfig/caBundle",
        "/webhooks/5/clientConfig/caBundle",
        "/webhooks/6/clientConfig/caBundle",
        "/webhooks/7/clientConfig/caBundle",
        "/webhooks/8/clientConfig/caBundle",
        "/webhooks/9/clientConfig/caBundle"
      ]
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "istio-system"
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_namespace.istio
  ]
}
