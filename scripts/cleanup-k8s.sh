#!/bin/bash
set -e

# Kubernetes Cleanup Script
# This script removes all deployments from the Kubernetes cluster

echo "========================================="
echo "🗑️  Kubernetes Cleanup"
echo "========================================="

NAMESPACE="estate"

read -p "Are you sure you want to delete all resources in namespace '$NAMESPACE'? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo "Deleting resources..."

# Delete services
kubectl delete svc --all -n $NAMESPACE --ignore-not-found=true

# Delete deployments
kubectl delete deployment --all -n $NAMESPACE --ignore-not-found=true

# Delete configmaps
kubectl delete configmap --all -n $NAMESPACE --ignore-not-found=true

# Delete secrets
kubectl delete secret --all -n $NAMESPACE --ignore-not-found=true

# Delete PVCs
kubectl delete pvc --all -n $NAMESPACE --ignore-not-found=true

# Delete namespace
kubectl delete namespace $NAMESPACE --ignore-not-found=true

echo "✅ Cleanup complete!"
