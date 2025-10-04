# Провайдер для Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Провайдер для Helm
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}