# -----------------------------------------------------
# INSTALL ARGOCD
# -----------------------------------------------------

data "http" "argocd" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.8/manifests/install.yaml"
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
