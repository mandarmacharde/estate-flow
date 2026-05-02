#!/bin/bash
# Complete Kubernetes Deployment - All-in-One
# This script deploys everything with a single command

set -e

NAMESPACE="estate"
DOCKER_USERNAME="${1:-your-docker-username}"
DOCKER_IMAGE_PREFIX="${DOCKER_USERNAME}/estate-flow"
BUILD_VERSION="${2:-latest}"

echo "========================================="
echo "🚀 COMPLETE KUBERNETES DEPLOYMENT"
echo "========================================="
echo ""
echo "Configuration:"
echo "  Namespace: $NAMESPACE"
echo "  Docker Image Prefix: $DOCKER_IMAGE_PREFIX"
echo "  Build Version: $BUILD_VERSION"
echo ""

# Verify kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi

# Verify cluster connectivity
echo "Verifying Kubernetes cluster..."
kubectl cluster-info > /dev/null || exit 1
echo "✅ Connected to cluster"
echo ""

# Step 1: Create namespace
echo "Step 1: Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Namespace created"
echo ""

# Step 2: Apply secrets
echo "Step 2: Applying secrets..."
kubectl apply -f k8s/secrets/db-secret.yaml
echo "✅ Secrets applied"
echo ""

# Step 3: Apply configmaps
echo "Step 3: Applying configuration maps..."
kubectl apply -f k8s/configmaps/backend-config.yaml
kubectl apply -f k8s/mysql/mysql-configmap.yaml
kubectl apply -f k8s/monitoring/prometheus-config.yaml
echo "✅ ConfigMaps applied"
echo ""

# Step 4: Deploy MySQL
echo "Step 4: Deploying MySQL database..."
kubectl apply -f k8s/mysql/mysql-pvc.yaml
kubectl apply -f k8s/mysql/mysql-deployment.yaml
kubectl apply -f k8s/mysql/mysql-service.yaml
echo "  Waiting for MySQL to be ready... (this may take 2-3 minutes)"
kubectl rollout status deployment/mysql-deployment -n $NAMESPACE --timeout=10m
echo "✅ MySQL deployed and ready"
echo ""

# Step 5: Deploy Backend
echo "Step 5: Deploying Backend API..."
# Update image tag
sed "s|DOCKER_REGISTRY/DOCKER_IMAGE:BACKEND_TAG|${DOCKER_IMAGE_PREFIX}-backend:${BUILD_VERSION}|g" k8s/backend/backend-deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/backend/backend-service.yaml
echo "  Waiting for Backend to be ready..."
kubectl rollout status deployment/backend-deployment -n $NAMESPACE --timeout=10m
echo "✅ Backend deployed and ready"
echo ""

# Step 6: Deploy Frontend
echo "Step 6: Deploying Frontend..."
# Update image tag
sed "s|DOCKER_REGISTRY/DOCKER_IMAGE:FRONTEND_TAG|${DOCKER_IMAGE_PREFIX}-frontend:${BUILD_VERSION}|g" k8s/frontend/frontend-deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/frontend/frontend-service.yaml
echo "  Waiting for Frontend to be ready..."
kubectl rollout status deployment/frontend-deployment -n $NAMESPACE --timeout=10m
echo "✅ Frontend deployed and ready"
echo ""

# Step 7: Deploy Monitoring
echo "Step 7: Deploying Monitoring Stack..."
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/prometheus-service.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-service.yaml
echo "  Waiting for Prometheus..."
kubectl rollout status deployment/prometheus-deployment -n $NAMESPACE --timeout=5m
echo "  Waiting for Grafana..."
kubectl rollout status deployment/grafana-deployment -n $NAMESPACE --timeout=5m
echo "✅ Monitoring stack deployed"
echo ""

# Step 8: Verify and display information
echo "========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "========================================="
echo ""

# Get node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

echo "📊 SERVICE ENDPOINTS:"
echo "  Frontend:    http://$NODE_IP:30080"
echo "  Backend:     http://$NODE_IP:30000"
echo "  Prometheus:  http://$NODE_IP:30090"
echo "  Grafana:     http://$NODE_IP:30300 (admin:admin)"
echo ""

echo "📋 POD STATUS:"
kubectl get pods -n $NAMESPACE -o wide
echo ""

echo "🔗 SERVICE STATUS:"
kubectl get svc -n $NAMESPACE
echo ""

echo "💾 STORAGE STATUS:"
kubectl get pvc -n $NAMESPACE
echo ""

echo "✅ All systems operational!"
echo ""
echo "Next steps:"
echo "1. Wait 1-2 minutes for all pods to be fully ready"
echo "2. Test frontend: curl http://$NODE_IP:30080"
echo "3. Test backend: curl http://$NODE_IP:30000/api/properties"
echo "4. View logs: kubectl logs -f deployment/DEPLOYMENT_NAME -n $NAMESPACE"
echo ""
echo "To delete deployment: ./scripts/cleanup-k8s.sh"
