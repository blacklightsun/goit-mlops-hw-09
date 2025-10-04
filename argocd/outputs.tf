# Outputs
output "argocd_server_service" {
  value = "Перейдіть до ArgoCD UI через: kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

output "get_argocd_admin_password" {
  description = "Command to get ArgoCD admin password"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}