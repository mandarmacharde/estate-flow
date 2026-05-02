#!/bin/bash
set -e

# Production Kubernetes Deployment Script
# This script deploys the entire application to a Kubernetes cluster

echo "========================================="
echo "🚀 Production Kubernetes Deployment"
echo "========================================="

NAMESPACE="estate"
DOCKER_IMAGE_PREFIX="${DOCKER_USERNAME:-your-docker-username}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check cluster connectivity
echo "Checking Kubernetes cluster connection..."
kubectl cluster-info || { echo "❌ Cannot connect to Kubernetes cluster"; exit 1; }

# Create namespace
echo "Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Apply secrets
echo "Applying secrets..."
kubectl apply -f k8s/secrets/db-secret.yaml

# Apply config maps
echo "Applying configuration maps..."
kubectl apply -f k8s/configmaps/backend-config.yaml
kubectl apply -f k8s/mysql/mysql-configmap.yaml
kubectl apply -f k8s/monitoring/prometheus-config.yaml

# Deploy MySQL
echo "Deploying MySQL database..."
kubectl apply -f k8s/mysql/mysql-pvc.yaml
kubectl apply -f k8s/mysql/mysql-deployment.yaml
kubectl apply -f k8s/mysql/mysql-service.yaml

# Wait for MySQL
echo "Waiting for MySQL to be ready..."
kubectl rollout status deployment/mysql-deployment -n $NAMESPACE --timeout=10m
sleep 10

# Deploy Backend
echo "Deploying Backend API..."
kubectl apply -f k8s/backend/backend-deployment.yaml
kubectl apply -f k8s/backend/backend-service.yaml

# Wait for Backend
echo "Waiting for Backend to be ready..."
kubectl rollout status deployment/backend-deployment -n $NAMESPACE --timeout=10m

# Deploy Frontend
echo "Deploying Frontend..."
kubectl apply -f k8s/frontend/frontend-deployment.yaml
kubectl apply -f k8s/frontend/frontend-service.yaml

# Wait for Frontend
echo "Waiting for Frontend to be ready..."
kubectl rollout status deployment/frontend-deployment -n $NAMESPACE --timeout=10m

# Deploy Monitoring
echo "Deploying Monitoring Stack..."
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/prometheus-service.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-service.yaml

echo ""
echo "========================================="
echo "✅ Deployment Complete!"
echo "========================================="
echo ""

# Get node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

echo "📊 Service URLs:"
echo "  Frontend:    http://$NODE_IP:30080"
echo "  Backend:     http://$NODE_IP:30000"
echo "  Prometheus:  http://$NODE_IP:30090"
echo "  Grafana:     http://$NODE_IP:30300 (admin:admin)"
echo ""

# Show pod status
echo "Pod Status:"
kubectl get pods -n $NAMESPACE

echo ""
echo "Service Status:"
kubectl get svc -n $NAMESPACE
