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
# INSTALL TRAEFIK
# -----------------------------------------------------

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik-system"
  }
}

resource "argocd_application" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "argocd"
  }

  wait = true

  spec {
    source {
      repo_url        = "https://helm.traefik.io/traefik"
      chart           = "traefik"
      target_revision = "10.24.0"
      helm {
        values = <<EOT
image:
  tag: "2.8.1"
logs:
  general:
    format: json
    level: INFO
  access:
    enabled: true
ports:
  traefik:
    port: 9000
    expose: true
  metrics:
    port: 9100
    expose: true
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "300m"
    memory: "150Mi"
EOT
      }
    }

    sync_policy {
      automated = {
        prune     = true
        self_heal = true
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
      namespace = "traefik-system"
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_namespace.traefik
  ]
}