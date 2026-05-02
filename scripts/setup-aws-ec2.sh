#!/bin/bash
set -e

# AWS EC2 Instance Setup Script
# This script prepares an Ubuntu EC2 instance for Kubernetes deployment
# Usage: chmod +x setup-aws-ec2.sh && ./setup-aws-ec2.sh

echo "========================================="
echo "🚀 AWS EC2 Setup for Kubernetes"
echo "========================================="

# Update system packages
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

echo "✅ Docker installed successfully"

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "✅ kubectl installed successfully"

# Install k3s (Lightweight Kubernetes)
echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Wait for k3s to be ready
echo "Waiting for k3s to be ready..."
sleep 30
sudo k3s kubectl get nodes

echo "✅ k3s installed successfully"

# Configure kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

# Install Jenkins
echo "Installing Jenkins..."
sudo apt-get install -y openjdk-11-jdk

# Install Jenkins using Docker
docker run -d --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

echo "⏳ Jenkins is starting... (this may take a few minutes)"
sleep 10

# Get Jenkins initial admin password
echo ""
echo "========================================="
echo "✅ All installations complete!"
echo "========================================="
echo ""
echo "🔐 Jenkins Initial Admin Password:"
docker logs jenkins | grep -A 5 "Please use the following password"
echo ""
echo "📊 Service URLs:"
echo "  Jenkins:     http://YOUR_EC2_IP:8080"
echo "  Kubernetes:  kubectl configured"
echo ""
echo "Next steps:"
echo "1. Access Jenkins at http://YOUR_EC2_IP:8080"
echo "2. Use the password above to login"
echo "3. Install required plugins (Docker, Kubernetes, Git)"
echo "4. Create a new Pipeline job pointing to your GitHub repository"
echo ""

# Show available nodes
echo "Kubernetes Nodes:"
kubectl get nodes
