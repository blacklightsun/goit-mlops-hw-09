# Створення namespace для ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# Встановлення ArgoCD через Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.46.7"

  values = [
    yamlencode({
      server = {
        service = {
          type = "NodePort"
        }
        # Відключення HTTPS для локального тестування
        extraArgs = [
          "--insecure"
        ]
      }
      
      # Конфігурація для роботи з приватними репозиторіями
      configs = {
        repositories = {
          "mlflow-repo" = {
            url = var.mlflow_repo_url
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}
