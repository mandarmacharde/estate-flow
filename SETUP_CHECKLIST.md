# 🎯 DevOps Setup - Complete File List & Instructions

## 📂 New Files Created

### Core Documentation
✅ **[DEVOPS_README.md](DEVOPS_README.md)** - Overview & quick start guide  
✅ **[DEVOPS_GUIDE.md](DEVOPS_GUIDE.md)** - Complete 50+ page deployment guide  
✅ **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture & design decisions  
✅ **[QUICK_COMMANDS.md](QUICK_COMMANDS.md)** - Command reference & debugging  
✅ **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** - This file (setup instructions)

### Updated Files
✅ **backend/Dockerfile** - Production-grade multi-stage build  
✅ **frontend/Dockerfile** - Nginx Alpine with multi-stage build  
✅ **docker-compose.yml** - Enhanced with networking, health checks, volumes  
✅ **.env.example** - Environment configuration template

### Kubernetes Manifests (`k8s/`)
```
k8s/
├── namespaces/
│   └── namespace.yaml                    ✅ Estate namespace definition
├── secrets/
│   ├── db-secret.yaml                    ✅ Database credentials
│   └── registry-secret.yaml              ✅ Docker registry credentials (template)
├── configmaps/
│   └── backend-config.yaml               ✅ Backend configuration
├── mysql/
│   ├── mysql-configmap.yaml              ✅ DB initialization script
│   ├── mysql-pvc.yaml                    ✅ Persistent volume for MySQL
│   ├── mysql-deployment.yaml             ✅ MySQL stateful deployment
│   └── mysql-service.yaml                ✅ MySQL internal service
├── backend/
│   ├── backend-deployment.yaml           ✅ Backend API deployment (2 replicas)
│   └── backend-service.yaml              ✅ Backend NodePort service (30000)
├── frontend/
│   ├── frontend-deployment.yaml          ✅ Frontend deployment (2 replicas)
│   └── frontend-service.yaml             ✅ Frontend NodePort service (30080)
└── monitoring/
    ├── prometheus-config.yaml            ✅ Prometheus configuration
    ├── prometheus-deployment.yaml        ✅ Prometheus deployment
    ├── prometheus-service.yaml           ✅ Prometheus service (30090)
    ├── grafana-deployment.yaml           ✅ Grafana deployment
    └── grafana-service.yaml              ✅ Grafana service (30300)
```

### Jenkins & CI/CD
✅ **Jenkinsfile** - Complete production pipeline with 8 stages

### Deployment Scripts (`scripts/`)
```
scripts/
├── deploy-local.sh                       ✅ Local docker-compose deployment
├── deploy-k8s.sh                         ✅ Kubernetes deployment
├── deploy-complete.sh                    ✅ All-in-one deployment
├── setup-aws-ec2.sh                      ✅ AWS EC2 instance setup
├── cleanup-k8s.sh                        ✅ Kubernetes resource cleanup
├── update-image-tags.sh                  ✅ Image tag management
└── make-executable.sh                    ✅ Make scripts executable
```

### GitHub Integration
✅ **.github/workflows/deploy.yml** - GitHub Actions CI/CD pipeline (alternative to Jenkins)

### Monitoring Configuration
✅ **monitoring/prometheus.yml** - Updated with Kubernetes support  
✅ **monitoring/promtail-config.yml** - Log aggregation configuration

---

## 🚀 DEPLOYMENT INSTRUCTIONS

### Step 1: Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/estate-flow.git
cd estate-flow
```

### Step 2: Make Scripts Executable
```bash
chmod +x scripts/make-executable.sh
./scripts/make-executable.sh

# Or manually
chmod +x scripts/*.sh
```

### Step 3: Choose Deployment Method

---

## 🐳 Option A: Local Docker Compose

### Prerequisites
- Docker installed and running
- Docker Compose installed
- 4GB RAM, 2 CPU cores

### Deployment
```bash
# 1. Copy environment file
cp .env.example .env

# 2. Deploy
./scripts/deploy-local.sh

# 3. Access services
# Frontend:    http://localhost:8080
# Backend:     http://localhost:5000
# Prometheus:  http://localhost:9090
# Grafana:     http://localhost:3000 (admin:admin)
```

### Verify
```bash
docker-compose ps
curl http://localhost:5000/api/properties
```

### Stop
```bash
docker-compose down
docker-compose down -v  # Remove volumes too
```

---

## ☸️ Option B: Kubernetes with k3s

### Prerequisites
- Ubuntu 20.04+ or similar Linux
- 2GB RAM, 2 CPU cores
- 20GB disk space

### Installation
```bash
# 1. Install k3s (lightweight Kubernetes)
curl -sfL https://get.k3s.io | sh -

# 2. Configure kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

# 3. Verify
kubectl get nodes
```

### Deployment
```bash
# 1. Copy environment file
cp .env.example .env

# 2. Deploy everything with one command
./scripts/deploy-k8s.sh

# 3. Get service endpoints (shown at end of script)
# Frontend:    http://NODE_IP:30080
# Backend:     http://NODE_IP:30000
# Prometheus:  http://NODE_IP:30090
# Grafana:     http://NODE_IP:30300
```

### Verify
```bash
kubectl get pods -n estate
kubectl get svc -n estate
kubectl get pvc -n estate

# View logs
kubectl logs -f deployment/backend-deployment -n estate

# Port forward for testing
kubectl port-forward svc/backend-service 5000:5000 -n estate
curl http://localhost:5000/api/properties
```

### Scale
```bash
# Scale backend to 5 replicas
kubectl scale deployment backend-deployment --replicas=5 -n estate

# Scale frontend to 5 replicas
kubectl scale deployment frontend-deployment --replicas=5 -n estate
```

### Cleanup
```bash
./scripts/cleanup-k8s.sh
```

---

## 🏗️ Option C: AWS EC2 Deployment

### Prerequisites
- AWS Account
- EC2 instance: Ubuntu 20.04 LTS
- Instance type: t3.medium (minimum for production)
- Storage: 20GB
- Security Group: Open ports 22, 80, 443, 8080, 30000-30400

### Setup
```bash
# 1. SSH into EC2 instance
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# 2. Clone repository
git clone https://github.com/YOUR_USERNAME/estate-flow.git
cd estate-flow

# 3. Run complete setup (installs Docker, k3s, Jenkins)
chmod +x scripts/setup-aws-ec2.sh
./scripts/setup-aws-ec2.sh

# This will:
# - Update system packages
# - Install Docker
# - Install kubectl
# - Install k3s
# - Install Jenkins in Docker
# - Display Jenkins initial password
```

### Access Services
```
Jenkins:     http://YOUR_EC2_IP:8080
Kubernetes:  kubectl configured
```

### Deploy Application
```bash
./scripts/deploy-complete.sh

# Services accessible at:
# Frontend:    http://YOUR_EC2_IP:30080
# Backend:     http://YOUR_EC2_IP:30000
# Prometheus:  http://YOUR_EC2_IP:30090
# Grafana:     http://YOUR_EC2_IP:30300
```

---

## 🔄 Option D: Jenkins CI/CD Pipeline

### Prerequisites
- Jenkins running (Docker container or standalone)
- Docker installed and accessible to Jenkins
- Kubernetes cluster configured
- Docker Hub account

### Setup Jenkins

1. **Access Jenkins**
   ```
   http://JENKINS_IP:8080
   ```

2. **Get Initial Password**
   ```bash
   docker logs jenkins | grep "Please use the following password"
   ```

3. **Install Plugins**
   - Go to Manage Jenkins → Plugin Manager
   - Install: Docker Pipeline, Kubernetes, GitHub Integration, Git

4. **Configure Credentials**
   ```
   Manage Jenkins → Manage Credentials → Add Credentials
   ```
   - Docker credentials (docker-username, docker-registry)
   - GitHub credentials (github-token)
   - Kubernetes config (kubeconfig)

5. **Create Pipeline Job**
   - New Item → Pipeline → Name: "estate-flow-pipeline"
   - Pipeline → Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/estate-flow.git`
   - Script Path: `Jenkinsfile`

### Trigger Pipeline
```bash
# Manual: Click "Build Now" in Jenkins
# Automatic: Configure GitHub webhook (see GitHub Integration section)
```

---

## 🔗 GitHub Integration (Webhook)

### Setup GitHub Webhook

1. **GitHub Settings**
   - Go to Settings → Webhooks
   - Click "Add webhook"

2. **Configure Webhook**
   ```
   Payload URL: http://JENKINS_IP:8080/github-webhook/
   Content type: application/json
   Events: Push events, Pull requests
   Active: ✓
   ```

3. **Test Webhook**
   ```bash
   git push origin main
   # Jenkins should automatically trigger the pipeline
   ```

### GitHub Actions Alternative
Already configured in `.github/workflows/deploy.yml`

```bash
# Add GitHub secrets:
# DOCKER_USERNAME - your Docker Hub username
# DOCKER_PASSWORD - your Docker Hub password
# KUBECONFIG - base64 encoded kubeconfig file
```

---

## 📊 Monitoring Setup

### Access Monitoring Dashboards

#### Prometheus
```
URL: http://NODE_IP:9090 or http://localhost:9090
- Explore metrics
- Graph data
- Check scrape targets
```

#### Grafana
```
URL: http://NODE_IP:3000 or http://localhost:3000
Username: admin
Password: admin (change this!)
```

### Add Grafana Dashboard

1. **Create Data Source**
   - Configuration → Data Sources → Add data source
   - Type: Prometheus
   - URL: http://prometheus:9090 (Kubernetes) or http://localhost:9090 (Docker)
   - Click "Save & Test"

2. **Import Dashboard**
   - Create → Import
   - Search for "Kubernetes Cluster Monitoring" (ID: 7249)
   - Select Prometheus data source
   - Import

---

## 🔐 Security Configuration

### Update Credentials Before Production

1. **Database Credentials**
   ```bash
   # Edit: k8s/secrets/db-secret.yaml
   kubectl apply -f k8s/secrets/db-secret.yaml
   ```

2. **Grafana Admin Password**
   - Grafana → Configuration → Users
   - Change default admin password

3. **Jenkins Admin Password**
   - Jenkins → Manage Jenkins → Configure Global Security
   - Set secure password

4. **Docker Registry Credentials**
   - Create Docker Hub Personal Access Token
   - Add to Jenkins credentials

---

## 📝 Configuration Files

### Edit .env File
```bash
cp .env.example .env
# Update with your values:
# - DB credentials
# - Docker registry
# - Grafana password
```

### Database Initialization
```bash
# MySQL runs init.sql automatically
# Modify: backend/init.sql
# Schema: properties and users tables
```

### Backend Configuration
```bash
# Edit: k8s/configmaps/backend-config.yaml
# Update: DB_HOST, DB_NAME, NODE_ENV
kubectl apply -f k8s/configmaps/backend-config.yaml
```

---

## 🐛 Common Issues & Solutions

### Issue: "Pod stuck in Pending"
```bash
kubectl describe pod POD_NAME -n estate
kubectl logs POD_NAME -n estate --previous
```

### Issue: "ImagePullBackOff"
```bash
# Create registry secret
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=USERNAME \
  --docker-password=PASSWORD \
  -n estate
```

### Issue: "MySQL connection refused"
```bash
# Wait for MySQL to be ready
kubectl get pod -l app=mysql -n estate
kubectl logs deployment/mysql-deployment -n estate
```

### Issue: "Cannot connect to backend"
```bash
# Test backend connectivity
kubectl port-forward svc/backend-service 5000:5000 -n estate
curl http://localhost:5000/api/properties
```

---

## 📈 Scaling & Performance

### Scale Deployments
```bash
# Backend
kubectl scale deployment backend-deployment --replicas=5 -n estate

# Frontend
kubectl scale deployment frontend-deployment --replicas=5 -n estate
```

### Monitor Resources
```bash
kubectl top nodes
kubectl top pods -n estate
```

### Update Resource Limits
```bash
kubectl edit deployment backend-deployment -n estate
# Update: resources.requests and resources.limits
```

---

## ✅ Final Verification Checklist

After deployment, verify all components:

- [ ] Frontend is accessible and loads without errors
- [ ] Backend API responds: `curl http://IP:PORT/api/properties`
- [ ] MySQL database is initialized
- [ ] Backend connects to database successfully
- [ ] Prometheus is collecting metrics
- [ ] Grafana dashboard displays data
- [ ] All pods are in Running state
- [ ] All services are created
- [ ] Jenkins pipeline builds successfully
- [ ] GitHub webhook triggers pipeline on push

---

## 🎓 Learning Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [Prometheus Monitoring](https://prometheus.io/docs/)
- [Grafana Dashboards](https://grafana.com/docs/)

---

## 📚 Related Documentation

- [DEVOPS_README.md](DEVOPS_README.md) - Overview & quick start
- [DEVOPS_GUIDE.md](DEVOPS_GUIDE.md) - Comprehensive guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [QUICK_COMMANDS.md](QUICK_COMMANDS.md) - Command reference

---

## 🎯 Next Steps

1. **Choose deployment method** (Docker Compose, Kubernetes, or AWS)
2. **Follow the relevant section above**
3. **Verify all services are running**
4. **Configure monitoring dashboard**
5. **Setup CI/CD pipeline**
6. **Configure GitHub webhook**
7. **Make changes and test automatic deployment**

---

**Complete! Your production-grade DevOps setup is ready.**

Version: 1.0  
Last Updated: May 2026  
Status: ✅ Ready for Deployment
