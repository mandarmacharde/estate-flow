# Architecture & Design Documentation

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
└────────────────────────┬────────────────────────────────────┘
                         │ Webhook
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Jenkins CI/CD                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 1. Checkout  2. Test  3. Build  4. Push  5. Deploy   │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │  Docker  │   │  Docker  │   │ K8s      │
    │ Registry │   │ Images   │   │ Cluster  │
    └──────────┘   └──────────┘   └────┬─────┘
                                        │
        ┌───────────────────────────────┼────────────────────────────────┐
        │                               │                                │
        ▼                               ▼                                ▼
    ┌─────────────┐          ┌─────────────────────────┐     ┌──────────────────┐
    │   MySQL     │          │    Backend (2 pods)     │     │ Frontend (2 pods)│
    │  (Stateful) │          │   - Express API         │     │  - Nginx         │
    └─────────────┘          │   - Port: 5000          │     │  - Port: 80      │
                             │   - Load Balanced       │     │  - Load Balanced │
                             └─────────────────────────┘     └──────────────────┘
                                        │                            │
                                        └────────────┬───────────────┘
                                                     │
                                      ┌──────────────┴──────────────┐
                                      │                             │
                                      ▼                             ▼
                              ┌──────────────────┐     ┌──────────────────────┐
                              │  Prometheus      │     │  Grafana             │
                              │  - Metrics       │     │  - Dashboards        │
                              │  - Storage       │     │  - Alerts            │
                              └──────────────────┘     └──────────────────────┘
```

## 📦 Component Details

### Backend (Node.js Express)
- **Container**: Docker with Alpine Linux (minimal size)
- **Multi-stage build**: Separates build from runtime
- **Health checks**: HTTP endpoint for liveness & readiness probes
- **Environment-based configuration**: DB connection from env vars
- **Non-root user**: Security best practice
- **Resource limits**: 128Mi memory request, 256Mi limit
- **Replicas**: 2 for high availability
- **Service**: ClusterIP internally, NodePort externally (port 30000)

### Frontend (React/HTML)
- **Server**: Nginx Alpine
- **Multi-stage build**: Optimized production image
- **Static file serving**: All HTML/CSS/JS served by Nginx
- **Config-driven**: Backend URL from environment
- **Security**: Non-root Nginx user
- **Resource limits**: 64Mi memory request, 128Mi limit
- **Replicas**: 2 for high availability
- **Service**: NodePort (port 30080)

### Database (MySQL)
- **Image**: MySQL 8.0
- **Persistence**: PersistentVolumeClaim (10Gi)
- **Initialization**: SQL script from ConfigMap
- **Secrets**: Credentials from Kubernetes Secret
- **Service**: ClusterIP (internal only)
- **Health checks**: mysqladmin ping probe
- **Single replica**: Stateful application

### Monitoring Stack

#### Prometheus
- **Scrape interval**: 15 seconds
- **Storage**: EmptyDir (can be upgraded to PersistentVolume)
- **Config**: ConfigMap with scrape targets
- **Service**: NodePort (port 30090)
- **Resource limits**: 256Mi memory, 100m CPU

#### Grafana
- **Admin user**: admin (default password: admin)
- **Data source**: Prometheus
- **Storage**: EmptyDir for dashboards
- **Service**: NodePort (port 30300)
- **Resource limits**: 128Mi memory, 50m CPU

## 🔄 CI/CD Pipeline Flow

### Stage 1: Checkout
- Git clone from GitHub repository
- Fetch all branches and tags

### Stage 2: Install Dependencies
- Backend: `npm install` (parallel)
- Frontend: `npm install || true` (silent fail for static HTML)

### Stage 3: Lint & Test
- Backend: Run ESLint and unit tests (parallel)
- Frontend: Run tests if configured

### Stage 4: Build Docker Images
- Backend Dockerfile with multi-stage build
- Frontend Dockerfile with Nginx
- Tag with BUILD_NUMBER and latest
- Parallel builds for speed

### Stage 5: Push to Registry
- Docker login with credentials
- Push backend image (tagged & latest)
- Push frontend image (tagged & latest)
- Docker logout for security

### Stage 6: Update K8s Manifests
- Replace IMAGE_TAG placeholder with BUILD_NUMBER
- Ensures correct version deployment

### Stage 7: Deploy to Kubernetes
- Create namespace (if not exists)
- Apply secrets and configmaps
- Deploy MySQL and wait for readiness
- Deploy backend and wait for rollout
- Deploy frontend and wait for rollout
- Deploy monitoring stack

### Stage 8: Verify Deployment
- Check pods are running
- Check services are created
- Display pod and service status

## 🔐 Security Best Practices

### Image Security
✅ Multi-stage builds reduce final image size
✅ Alpine Linux base (minimal dependencies)
✅ Non-root user execution
✅ No secrets in images
✅ Read-only filesystems where possible

### Kubernetes Security
✅ Namespace isolation
✅ Secrets for sensitive data (not ConfigMaps)
✅ ConfigMaps for configuration
✅ Resource limits prevent resource exhaustion
✅ Network policies (can be added)
✅ RBAC (can be configured)
✅ Security context with runAsNonRoot

### CI/CD Security
✅ Credentials stored as Jenkins secrets
✅ Credentials in environment, not hardcoded
✅ Docker credentials cleared after push
✅ Webhook validation with GitHub

## 📊 Networking

### Service Discovery
- MySQL: `mysql-service:3306` (internal)
- Backend: `backend-service:5000` (internal) or `NODE_IP:30000` (external)
- Frontend: `frontend-service:80` (internal) or `NODE_IP:30080` (external)
- Prometheus: `NODE_IP:30090` (external)
- Grafana: `NODE_IP:30300` (external)

### DNS Resolution
- Kubernetes DNS: `service-name.namespace.svc.cluster.local`
- Example: `mysql-service.estate.svc.cluster.local:3306`

## 🔄 Database Connectivity

### Development (Docker Compose)
- Backend connects via: `mysql:3306`
- Container name used as hostname

### Production (Kubernetes)
- Backend connects via: `mysql-service:3306`
- Service DNS used for hostname

### Connection String
```javascript
const pool = mysql.createPool({
  host: process.env.DB_HOST,      // kubernetes: "mysql-service"
  user: process.env.DB_USER,      // From Secret
  password: process.env.DB_PASSWORD, // From Secret
  database: process.env.DB_NAME   // From ConfigMap
});
```

## 📈 Scaling Strategy

### Horizontal Scaling
- Backend: Increase replicas in deployment
- Frontend: Increase replicas in deployment
- MySQL: Consider read replicas or managed database

### Vertical Scaling
- Increase resource requests/limits
- Upgrade node machine types

### Auto Scaling (Future)
- Horizontal Pod Autoscaler (HPA) based on CPU/memory
- Cluster Autoscaler for nodes

## 🔍 Monitoring & Observability

### Metrics Collected
- Container CPU usage
- Container memory usage
- Pod restart counts
- API request latency
- Network I/O
- Disk usage
- Database connection pools

### Dashboards Available
- Kubernetes cluster overview
- Pod resource usage
- Node metrics
- Application-specific metrics

### Alerting (Can be configured)
- High memory usage
- High CPU usage
- Pod crash loops
- Database connection errors

## 🚀 Deployment Modes

### 1. Local Development
```bash
docker-compose up
# All services on localhost
```

### 2. Kubernetes on Local Machine
```bash
# Using Docker Desktop Kubernetes or Minikube
kubectl apply -f k8s/
```

### 3. AWS EC2 with k3s
```bash
# Lightweight Kubernetes on EC2
./scripts/setup-aws-ec2.sh
./scripts/deploy-k8s.sh
```

### 4. Managed Kubernetes (EKS, GKE, AKS)
```bash
# Production-grade managed service
# Configure kubectl to connect
kubectl apply -f k8s/
```

## 📝 Environment Configuration

### Backend Environment Variables
```
DB_HOST=mysql-service          # Kubernetes service DNS
DB_USER=estate_user            # From Secret
DB_PASSWORD=estate_password    # From Secret
DB_NAME=estateflow             # From ConfigMap
NODE_ENV=production            # From ConfigMap
```

### Docker Compose Environment
```
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=estateflow
MYSQL_USER=estate_user
MYSQL_PASSWORD=estate_password
```

### Kubernetes Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
stringData:
  DB_USER: estate_user
  DB_PASSWORD: estate_password
```

## 🔄 Update Strategy

### Rolling Updates
- Max surge: 1 pod (one extra pod during update)
- Max unavailable: 0 (no pods down during update)
- Ensures zero-downtime deployments

### Image Update Process
1. New image tagged with BUILD_NUMBER
2. Manifest updated with new tag
3. kubectl apply triggers rolling update
4. Old pods terminated gracefully
5. New pods started
6. Health checks verify ready

## 📊 Performance Characteristics

### Image Sizes
- Backend: ~150MB (Node.js Alpine)
- Frontend: ~20MB (Nginx Alpine)
- Reduced from ~500MB+ with traditional images

### Container Startup Time
- Backend: ~5-10 seconds
- Frontend: ~2-3 seconds
- MySQL: ~10-15 seconds

### Memory Usage
- Backend pod: 64-128MB (actual usage)
- Frontend pod: 20-40MB
- MySQL: 256MB+

---

**Document Version**: 1.0
**Last Updated**: May 2026
