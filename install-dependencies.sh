#!/bin/bash

TERRAFORM_VERSION=1.2.6
# ARGOCD_VERSION=2.4.8

rm -rf bin
mkdir bin

echo "[INFO] install minikube"
curl -LsO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
mv minikube-linux-amd64 bin/minikube
chmod +x bin/minikube
bin/minikube version

echo "[INFO] install terraform"
curl -LsO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform bin/terraform
chmod +x bin/terraform
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
bin/terraform version

# echo "[INFO] install argocd"
# curl -LsO https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
# mv argocd-linux-amd64 bin/argocd
# chmod +x bin/argocd
# bin/argocd version
