#!/bin/bash

# Update image tags in Kubernetes manifests
# Usage: ./update-image-tags.sh <BUILD_NUMBER>

BUILD_NUMBER=${1:-latest}
DOCKER_USERNAME=${2:-your-docker-username}

BACKEND_IMAGE="${DOCKER_USERNAME}/estate-flow-backend:${BUILD_NUMBER}"
FRONTEND_IMAGE="${DOCKER_USERNAME}/estate-flow-frontend:${BUILD_NUMBER}"

echo "Updating image tags..."
echo "Backend Image: $BACKEND_IMAGE"
echo "Frontend Image: $FRONTEND_IMAGE"

# Update backend deployment
sed -i "s|DOCKER_REGISTRY/DOCKER_IMAGE:BACKEND_TAG|${BACKEND_IMAGE}|g" k8s/backend/backend-deployment.yaml

# Update frontend deployment
sed -i "s|DOCKER_REGISTRY/DOCKER_IMAGE:FRONTEND_TAG|${FRONTEND_IMAGE}|g" k8s/frontend/frontend-deployment.yaml

echo "✅ Image tags updated successfully"
