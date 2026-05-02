# Property Buy - Production-Grade DevOps Setup

A complete, production-ready DevOps infrastructure for a full-stack web application with Node.js backend, React frontend, MySQL database, and comprehensive monitoring.

## 📚 Documentation

1. **[DEVOPS_GUIDE.md](DEVOPS_GUIDE.md)** - Complete step-by-step deployment guide
2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design decisions
3. **[QUICK_COMMANDS.md](QUICK_COMMANDS.md)** - Quick reference for common commands

## 🚀 Quick Start (3 Options)

### Option 1: Local Docker Compose (Fastest)
```bash
chmod +x scripts/deploy-local.sh
./scripts/deploy-local.sh
```
- ✅ Frontend: http://localhost:8080
- ✅ Backend: http://localhost:5000
- ✅ Prometheus: http://localhost:9090
- ✅ Grafana: http://localhost:3000

### Option 2: Kubernetes with k3s (Lightweight)
```bash
# Install k3s first
curl -sfL https://get.k3s.io | sh -

# Deploy application
chmod +x scripts/deploy-k8s.sh
./scripts/deploy-k8s.sh
```

### Option 3: AWS EC2 (Production)
```bash
# Launch Ubuntu 20.04 EC2 instance (t3.medium or larger)
# SSH into instance and run:
chmod +x scripts/setup-aws-ec2.sh
./scripts/setup-aws-ec2.sh
```

## 📦 Project Structure

```
estate-flow/
├── backend/
│   ├── Dockerfile              ✅ Multi-stage optimized
│   ├── package.json
│   ├── server.js
│   └── init.sql
├── frontend/
│   ├── Dockerfile              ✅ Nginx Alpine multi-stage
│   ├── index.html
│   ├── nginx.conf
│   └── images/
├── k8s/                        ✅ Complete Kubernetes manifests
│   ├── namespaces/
│   ├── secrets/
│   ├── configmaps/
│   ├── mysql/
│   ├── backend/
│   ├── frontend/
│   └── monitoring/
├── monitoring/
│   ├── prometheus.yml
│   ├── promtail-config.yml
│   └── grafana-provisioning/
├── scripts/
│   ├── deploy-local.sh         ✅ Local deployment
│   ├── deploy-k8s.sh           ✅ Kubernetes deployment
│   ├── deploy-complete.sh      ✅ All-in-one deployment
│   ├── setup-aws-ec2.sh        ✅ AWS EC2 setup
│   ├── cleanup-k8s.sh          ✅ Resource cleanup
│   └── update-image-tags.sh    ✅ Tag management
├── docker-compose.yml          ✅ Production-grade compose
├── Jenkinsfile                 ✅ Complete CI/CD pipeline
├── .env.example                ✅ Configuration template
├── DEVOPS_GUIDE.md            ✅ Complete guide
├── ARCHITECTURE.md            ✅ Architecture docs
└── QUICK_COMMANDS.md          ✅ Command reference
```

## 🔧 What's Included

### Docker
- ✅ Optimized multi-stage Dockerfiles
- ✅ Production-grade docker-compose.yml
- ✅ Health checks configured
- ✅ Non-root user execution
- ✅ Minimal image sizes

### Kubernetes
- ✅ Complete manifests for all components
- ✅ Deployments with replicas (HA)
- ✅ Services (ClusterIP, NodePort)
- ✅ ConfigMaps for configuration
- ✅ Secrets for sensitive data
- ✅ PersistentVolumeClaims for data
- ✅ Liveness & readiness probes
- ✅ Resource requests & limits
- ✅ Rolling update strategy

### Jenkins CI/CD
- ✅ Complete Jenkinsfile pipeline
- ✅ Multi-stage: Checkout → Test → Build → Push → Deploy
- ✅ Docker image building & pushing
- ✅ Kubernetes deployment
- ✅ Parallel builds for efficiency
- ✅ Secure credential management

### Monitoring
- ✅ Prometheus for metrics collection
- ✅ Grafana for visualization
- ✅ Pre-configured dashboards
- ✅ Health check endpoints
- ✅ Container metrics

### AWS
- ✅ EC2 instance setup script
- ✅ k3s lightweight Kubernetes installation
- ✅ Jenkins containerized setup
- ✅ Docker pre-installed
- ✅ kubectl configured

## 📊 Features

| Feature | Status | Details |
|---------|--------|---------|
| **Docker** | ✅ | Multi-stage, Alpine, optimized |
| **Kubernetes** | ✅ | Full manifests with HA |
| **Jenkins** | ✅ | Complete CI/CD pipeline |
| **Monitoring** | ✅ | Prometheus + Grafana |
| **Database** | ✅ | MySQL with persistence |
| **Load Balancing** | ✅ | 2+ replicas per service |
| **Health Checks** | ✅ | Liveness & readiness probes |
| **Security** | ✅ | Non-root users, secrets |
| **AWS Ready** | ✅ | EC2 setup included |
| **GitHub Integration** | ✅ | Webhook support |
| **Scalability** | ✅ | Horizontal & vertical |
| **Documentation** | ✅ | Comprehensive guides |

## 🔐 Security Features

- Non-root user execution in containers
- Kubernetes secrets for sensitive data
- ConfigMaps for configuration
- ImagePullPolicy: IfNotPresent
- Resource limits prevent DoS
- Health checks for availability
- Namespace isolation
- Role-based access control ready

## 📈 Scaling

### Horizontal Scaling
```bash
# Scale backend to 5 replicas
kubectl scale deployment backend-deployment --replicas=5 -n estate

# Scale frontend to 5 replicas
kubectl scale deployment frontend-deployment --replicas=5 -n estate
```

### Vertical Scaling
Edit deployment resource requests/limits:
```bash
kubectl edit deployment backend-deployment -n estate
```

## 🔄 Deployment Pipeline

```
GitHub Push
    ↓
Jenkins Webhook Triggered
    ↓
Build Stage (Install deps, Lint, Test)
    ↓
Docker Build (Backend & Frontend)
    ↓
Push to Registry
    ↓
Update Kubernetes Manifests
    ↓
Deploy to Kubernetes
    ↓
Verify Deployment
    ↓
✅ Application Live
```

## 💻 System Requirements

### Local Development
- Docker & Docker Compose
- 4GB RAM minimum
- 2 CPU cores

### Kubernetes (k3s)
- Ubuntu 20.04+ or similar Linux
- 2GB RAM minimum (4GB recommended)
- 2 CPU cores
- 20GB disk space

### AWS EC2
- Instance type: t3.medium (t2.small for free tier)
- Ubuntu 20.04 LTS AMI
- Security group: Allow ports 22, 80, 443, 8080, 30000-30400
- 20GB storage

## 📝 Configuration

### Environment Variables
Update `.env` file:
```bash
cp .env.example .env
# Edit with your values
```

### Database Credentials
Update `k8s/secrets/db-secret.yaml` for Kubernetes:
```yaml
stringData:
  DB_USER: your_user
  DB_PASSWORD: your_password
  DB_ROOT_PASSWORD: your_root_password
```

### Docker Registry
Configure in Jenkins:
```
Jenkins → Manage Credentials
Add credentials for Docker Hub
Update docker-username and docker-registry
```

## 🐛 Troubleshooting

### Check pod status
```bash
kubectl get pods -n estate
kubectl describe pod POD_NAME -n estate
```

### View logs
```bash
kubectl logs deployment/DEPLOYMENT_NAME -n estate -f
```

### Debug connectivity
```bash
kubectl exec -it POD_NAME -n estate -- /bin/sh
```

### Port forward for local testing
```bash
kubectl port-forward svc/backend-service 5000:5000 -n estate
```

For detailed troubleshooting, see [QUICK_COMMANDS.md](QUICK_COMMANDS.md)

## 📚 Documentation

- **[DEVOPS_GUIDE.md](DEVOPS_GUIDE.md)** - 50+ page comprehensive guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture & design decisions
- **[QUICK_COMMANDS.md](QUICK_COMMANDS.md)** - Quick reference & debugging

## 🔗 Related Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/)
- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [k3s - Lightweight Kubernetes](https://k3s.io/)

## ✅ Deployment Checklist

- [ ] Docker images build successfully
- [ ] docker-compose works locally
- [ ] Kubernetes cluster accessible
- [ ] All manifests apply without errors
- [ ] All pods running
- [ ] Services accessible
- [ ] MySQL initialized
- [ ] Backend-DB connection working
- [ ] Frontend-Backend connection working
- [ ] Jenkins running
- [ ] GitHub webhook configured
- [ ] Pipeline triggers on push
- [ ] Prometheus collecting metrics
- [ ] Grafana dashboard accessible

## 🎯 Next Steps

1. **Test Locally**
   ```bash
   ./scripts/deploy-local.sh
   ```

2. **Deploy to Kubernetes**
   ```bash
   ./scripts/deploy-k8s.sh
   ```

3. **Setup CI/CD Pipeline**
   - Create Jenkins job
   - Point to this repository
   - Configure GitHub webhook

4. **Deploy to AWS**
   ```bash
   ./scripts/setup-aws-ec2.sh
   ./scripts/deploy-complete.sh
   ```

## 📞 Support

For issues or questions:
1. Check [QUICK_COMMANDS.md](QUICK_COMMANDS.md) troubleshooting section
2. Review logs: `kubectl logs -f deployment/NAME -n estate`
3. Check pod status: `kubectl describe pod POD_NAME -n estate`

## 📄 License

This DevOps setup is part of the Property Buy project.

---

**Version**: 1.0  
**Last Updated**: May 2026  
**Status**: ✅ Production Ready
