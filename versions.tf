terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.0.1"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "3.1.0"
    }
  }
}
