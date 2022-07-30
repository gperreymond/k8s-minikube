# -----------------------------------------------------
# INSTALL ARGOCD
# -----------------------------------------------------

data "http" "argocd" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.8/manifests/ha/install.yaml"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd.response_body
}

resource "kubectl_manifest" "argocd" {
  count = length(data.kubectl_file_documents.argocd.documents)

  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
  force_new          = true
  force_conflicts    = true

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# -----------------------------------------------------
# INSTALL ISTIO
# -----------------------------------------------------

resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system"
  }
}

resource "argocd_application" "istio-base" {
  metadata {
    name      = "istio-base"
    namespace = "argocd"
  }

  wait = false

  spec {
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

resource "argocd_application" "istio-gateway" {
  metadata {
    name      = "istio-gateway"
    namespace = "argocd"
  }

  wait = false

  spec {
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
    name      = "istiod"
    namespace = "argocd"
  }

  wait = false

  spec {
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

# -----------------------------------------------------
# INSTALL TRAEFIK
# -----------------------------------------------------

# resource "kubernetes_namespace" "traefik" {
#   metadata {
#     name = "traefik-system"
#   }
# }

# resource "argocd_application" "traefik" {
#   metadata {
#     name      = "traefik"
#     namespace = "argocd"
#   }

#   wait = false

#   spec {
#     source {
#       repo_url        = "https://helm.traefik.io/traefik"
#       chart           = "traefik"
#       target_revision = "10.24.0"
#       helm {
#         values = <<EOT
# image:
#   tag: "2.8.1"
# logs:
#   general:
#     format: json
#     level: INFO
#   access:
#     enabled: true
# ports:
#   traefik:
#     port: 9000
#     expose: true
#   metrics:
#     port: 9100
#     expose: true
# resources:
#   requests:
#     cpu: "100m"
#     memory: "50Mi"
#   limits:
#     cpu: "300m"
#     memory: "150Mi"
# EOT
#       }
#     }

#     sync_policy {
#       automated = {
#         prune       = true
#         self_heal   = true
#         allow_empty = false
#       }
#       retry {
#         limit = "5"
#         backoff = {
#           duration     = "30s"
#           max_duration = "2m"
#           factor       = "2"
#         }
#       }
#     }

#     destination {
#       server    = "https://kubernetes.default.svc"
#       namespace = "traefik-system"
#     }
#   }

#   depends_on = [
#     kubernetes_namespace.argocd,
#     kubernetes_namespace.traefik
#   ]
# }