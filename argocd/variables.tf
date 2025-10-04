variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
  
}

variable "mlflow_repo_url" {
  description = "URL of the MLflow Git repository"
  type        = string
  default     = "https://github.com/blacklightsun/goit-mlflow-platform.git"
}