# 🚀 Complete DevOps Setup Guide

This guide provides step-by-step instructions to deploy the Property Buy application using Docker, Kubernetes, and Jenkins.

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Docker Setup](#docker-setup)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Jenkins CI/CD Pipeline](#jenkins-cicd-pipeline)
5. [AWS Deployment](#aws-deployment)
6. [GitHub Integration](#github-integration)
7. [Monitoring](#monitoring)
8. [Troubleshooting](#troubleshooting)

---

## 🏃 Quick Start

### Option 1: Local Docker Compose (Fastest)
```bash
cd /Users/mandar/estate-flow
chmod +x scripts/deploy-local.sh
./scripts/deploy-local.sh
```

Access the application:
- Frontend: http://localhost:8080
- Backend: http://localhost:5000
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

### Option 2: Kubernetes (Production-Ready)
```bash
# Ensure kubectl is configured
kubectl get nodes

# Run deployment
chmod +x scripts/deploy-k8s.sh
./scripts/deploy-k8s.sh
```

---

## 🐳 Docker Setup

### Project Structure
```
estate-flow/
├── backend/
│   ├── Dockerfile          (Optimized multi-stage)
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── Dockerfile          (Nginx multi-stage)
│   ├── index.html
│   └── nginx.conf
├── docker-compose.yml      (Production-grade)
└── .env.example           (Configuration template)
```

### Building Images Manually
```bash
# Backend
docker build -t estate-flow-backend:latest ./backend

# Frontend
docker build -t estate-flow-frontend:latest ./frontend

# Test locally
docker-compose up -d
```

### Docker Best Practices Applied
✅ Multi-stage builds (reduced image size)
✅ Non-root user execution (security)
✅ Health checks (reliability)
✅ Proper resource limits
✅ Environment variable configuration

---

## ☸️ Kubernetes Deployment

### Prerequisites
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify cluster connection
kubectl cluster-info
kubectl get nodes
```

### Project Structure
```
k8s/
├── namespaces/
│   └── namespace.yaml
├── secrets/
│   ├── db-secret.yaml
│   └── registry-secret.yaml
├── configmaps/
│   └── backend-config.yaml
├── mysql/
│   ├── mysql-deployment.yaml
│   ├── mysql-service.yaml
│   ├── mysql-pvc.yaml
│   └── mysql-configmap.yaml
├── backend/
│   ├── backend-deployment.yaml
│   └── backend-service.yaml
├── frontend/
│   ├── frontend-deployment.yaml
│   └── frontend-service.yaml
└── monitoring/
    ├── prometheus-deployment.yaml
    ├── prometheus-service.yaml
    ├── grafana-deployment.yaml
    └── grafana-service.yaml
```

### Deployment Steps
```bash
# 1. Create namespace
kubectl create namespace estate

# 2. Apply all manifests in order
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/configmaps/
kubectl apply -f k8s/mysql/
kubectl apply -f k8s/backend/
kubectl apply -f k8s/frontend/
kubectl apply -f k8s/monitoring/

# 3. Verify deployment
kubectl get pods -n estate
kubectl get svc -n estate

# 4. Access services
# Get node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
echo "Frontend: http://$NODE_IP:30080"
echo "Backend: http://$NODE_IP:30000"
echo "Prometheus: http://$NODE_IP:30090"
echo "Grafana: http://$NODE_IP:30300"
```

### Key Kubernetes Features
✅ Deployment with 2 replicas (HA)
✅ Rolling updates (zero downtime)
✅ Service discovery via DNS
✅ ConfigMaps for configuration
✅ Secrets for sensitive data
✅ Health checks (liveness & readiness probes)
✅ Resource limits & requests
✅ Non-root security context

---

## 🔄 Jenkins CI/CD Pipeline

### Prerequisites
```bash
# Install Jenkins
docker run -d --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Get initial password
docker logs jenkins | grep "Please use the following password"
```

### Setup Jenkins

1. **Access Jenkins**: http://localhost:8080
2. **Install Plugins**:
   - Docker Pipeline
   - Kubernetes
   - GitHub Integration
   - Git

3. **Configure Credentials**:
   - Docker Hub credentials (docker-username, docker-registry)
   - GitHub credentials
   - Kubernetes config (kubeconfig)

4. **Create Pipeline Job**:
   - New Item → Pipeline
   - Name: "estate-flow-pipeline"
   - Pipeline → Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/estate-flow.git`
   - Script Path: `Jenkinsfile`

### Pipeline Stages
```
✅ Checkout - Clone repository
✅ Install Dependencies - npm install for backend & frontend
✅ Lint & Test - Run linting and unit tests
✅ Build Docker Images - Create optimized images
✅ Push to Registry - Push to Docker Hub
✅ Update K8s Manifests - Update image tags
✅ Deploy to Kubernetes - Apply to cluster
✅ Verify Deployment - Ensure pods are running
```

### Trigger Pipeline

**Manual**: Click "Build Now" in Jenkins
**Automatic**: GitHub webhook (see GitHub Integration section)

---

## 🏗️ AWS Deployment

### Setup EC2 Instance

1. **Launch EC2 Instance**
   - AMI: Ubuntu 20.04 LTS
   - Instance Type: t3.medium (FREE TIER: t2.micro/t2.small)
   - Storage: 20GB
   - Security Group: Allow ports 22, 80, 443, 8080, 30000-30400

2. **Run Setup Script**
   ```bash
   # SSH into instance
   ssh -i your-key.pem ubuntu@YOUR_EC2_IP

   # Clone repository
   git clone https://github.com/YOUR_USERNAME/estate-flow.git
   cd estate-flow

   # Run setup
   chmod +x scripts/setup-aws-ec2.sh
   ./scripts/setup-aws-ec2.sh
   ```

3. **Verify Installation**
   ```bash
   docker --version
   kubectl version --client
   k3s kubectl get nodes
   docker ps
   ```

### Access Services on AWS
```
Frontend:    http://YOUR_EC2_IP:30080
Backend:     http://YOUR_EC2_IP:30000
Jenkins:     http://YOUR_EC2_IP:8080
Prometheus:  http://YOUR_EC2_IP:30090
Grafana:     http://YOUR_EC2_IP:30300
```

---

## 🔗 GitHub Integration

### Setup GitHub Webhook

1. **GitHub Repository Settings**
   - Go to Settings → Webhooks
   - Click "Add webhook"

2. **Configure Webhook**
   - Payload URL: `http://YOUR_JENKINS_IP:8080/github-webhook/`
   - Content type: application/json
   - Events: Push events
   - Active: ✓

3. **Test Webhook**
   ```bash
   git push origin main
   # Jenkins should automatically trigger the pipeline
   ```

### GitHub Credentials in Jenkins
1. Jenkins → Manage Credentials
2. Add credentials:
   - Username: Your GitHub username
   - Password: GitHub personal access token
3. Select in pipeline job

---

## 📊 Monitoring

### Prometheus
- **URL**: http://localhost:9090 (Docker) or http://NODE_IP:30090 (K8s)
- **Config**: monitoring/prometheus.yml
- **Scrape Jobs**:
  - Prometheus self
  - Kubernetes API servers
  - Kubernetes nodes

### Grafana
- **URL**: http://localhost:3000 (Docker) or http://NODE_IP:30300 (K8s)
- **Login**: admin / admin
- **Data Source**: Prometheus (http://prometheus:9090)

### Adding Dashboard
1. Grafana → Dashboards → Import
2. Search for "Kubernetes Cluster Monitoring" (ID: 7249)
3. Select Prometheus as data source

### Available Metrics
- Container CPU/Memory usage
- Pod restarts
- API request latency
- Network I/O
- Disk usage

---

## 🐛 Troubleshooting

### Docker Issues

**Image build fails:**
```bash
docker build --no-cache -t estate-flow-backend:latest ./backend
```

**Port already in use:**
```bash
docker-compose down
docker system prune
```

### Kubernetes Issues

**Pod stuck in pending:**
```bash
kubectl describe pod POD_NAME -n estate
kubectl logs POD_NAME -n estate
```

**Service unreachable:**
```bash
kubectl port-forward svc/backend-service 5000:5000 -n estate
curl http://localhost:5000/api/properties
```

**MySQL connection error:**
```bash
# Check if MySQL is ready
kubectl exec -it mysql-deployment-POD_ID -n estate -- mysqladmin ping

# Check backend logs
kubectl logs deployment/backend-deployment -n estate
```

### Jenkins Issues

**Pipeline fails to connect to Kubernetes:**
- Verify kubeconfig is correctly added as secret
- Check Jenkins permissions to pull from Docker registry
- Ensure DOCKER_REGISTRY and DOCKER_USERNAME credentials are set

**Docker pull fails in Jenkins:**
- Login to Docker Hub: `docker login`
- Verify credentials in Jenkins
- Check image name and tag in Jenkinsfile

### Network Issues

**Can't access services from outside:**
```bash
# Check NodePort status
kubectl get svc -n estate

# Verify firewall rules (AWS Security Group)
# Allow inbound traffic on ports: 30080, 30000, 30090, 30300

# Test connectivity
curl -v http://YOUR_IP:30080
```

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [k3s Lightweight Kubernetes](https://k3s.io/)

---

## ✅ Deployment Checklist

- [ ] Docker images build successfully
- [ ] docker-compose up works locally
- [ ] Kubernetes cluster is accessible
- [ ] kubectl get nodes shows nodes
- [ ] All Kubernetes manifests apply without errors
- [ ] All pods are running: kubectl get pods -n estate
- [ ] Services are accessible
- [ ] MySQL is initialized
- [ ] Backend connects to database
- [ ] Frontend connects to backend
- [ ] Jenkins is running and accessible
- [ ] Jenkins credentials are configured
- [ ] GitHub webhook is working
- [ ] Pipeline builds and deploys successfully
- [ ] Prometheus is collecting metrics
- [ ] Grafana dashboard is accessible

---

**Last Updated**: May 2026
**Version**: 1.0
