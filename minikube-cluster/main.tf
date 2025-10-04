terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

# --- Старт Minikube ---
resource "null_resource" "minikube_start" {
  provisioner "local-exec" {
    command = <<EOT
minikube start \
  --nodes=${var.nodes} \
  --cpus=${var.cpus} \
  --memory=${var.memory} \
  --disk-size=${var.disk_size}g \
  --driver=${var.driver}
EOT
  }
}

# --- Увімкнення аддонів ---
resource "null_resource" "enable_addons" {
  depends_on = [null_resource.minikube_start]

  provisioner "local-exec" {
    command = <<EOT
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable storage-provisioner-rancher
EOT
  }
}

# --- Kubernetes provider підключається після старту Minikube ---
provider "kubernetes" {
  host                   = chomp(trimspace(shell("minikube ip")))
  config_path            = "~/.kube/config"
  load_config_file       = true
  cluster_ca_certificate = filebase64("${path.home}/.minikube/ca.crt")
  client_certificate     = filebase64("${path.home}/.minikube/client.crt")
  client_key             = filebase64("${path.home}/.minikube/client.key")

  # depends_on = [null_resource.enable_addons]
}
