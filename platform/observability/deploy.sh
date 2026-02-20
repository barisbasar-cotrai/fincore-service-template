#!/bin/bash
# Deploy the observability stack to AKS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Adding Helm repositories ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "=== Creating monitoring namespace ==="
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "=== Installing kube-prometheus-stack ==="
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values "${SCRIPT_DIR}/kube-prometheus-values.yaml" \
  --wait --timeout 5m

echo "=== Installing Loki + Promtail ==="
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --set loki.auth_enabled=false \
  --set promtail.enabled=true \
  --set grafana.enabled=false \
  --wait --timeout 5m

echo "=== Adding Loki as Grafana datasource ==="
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-datasource
  namespace: monitoring
  labels:
    grafana_datasource: "1"
data:
  loki-datasource.yaml: |
    apiVersion: 1
    datasources:
      - name: Loki
        type: loki
        access: proxy
        url: http://loki:3100
        isDefault: false
EOF

echo ""
echo "=== Observability stack deployed ==="
echo ""
echo "Grafana access:"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  URL:      http://localhost:3000"
echo "  User:     admin"
echo "  Password: fincore-demo"
