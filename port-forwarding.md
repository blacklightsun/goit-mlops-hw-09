#### ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

#### MLFlow UI
kubectl port-forward -n mlflow svc/mlflow-service 5000:5000

#### Minio API
kubectl port-forward -n minio svc/minio-service 9000:9000

#### Minio UI
kubectl port-forward -n minio svc/minio-service 9001:9001

#### AlertManager UI
kubectl -n monitoring port-forward svc/prometheus-operator-alertmanager 9093:9093

#### Grafana UI
kubectl -n monitoring port-forward svc/prometheus-operator-grafana 3000:80

#### PushGateWay UI
kubectl -n monitoring port-forward svc/prometheus-pushgateway 9091:9091

#### VEnv activation
source venv/bin/activate