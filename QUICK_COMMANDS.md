# Quick Deployment Commands Reference

## 🚀 ONE-COMMAND DEPLOYMENT

### Local Docker Compose
```bash
cd estate-flow && chmod +x scripts/deploy-local.sh && ./scripts/deploy-local.sh
```

### AWS EC2 Setup
```bash
# Run on new Ubuntu 20.04 EC2 instance
chmod +x scripts/setup-aws-ec2.sh && ./scripts/setup-aws-ec2.sh
```

### Kubernetes Deployment
```bash
# After kubectl is configured
chmod +x scripts/deploy-k8s.sh && ./scripts/deploy-k8s.sh
```

---

## 📊 ACCESS URLS

### Local (Docker Compose)
```
Frontend:    http://localhost:8080
Backend:     http://localhost:5000
Prometheus:  http://localhost:9090
Grafana:     http://localhost:3000
```

### AWS EC2 with Kubernetes
```
Frontend:    http://EC2_IP:30080
Backend:     http://EC2_IP:30000
Jenkins:     http://EC2_IP:8080
Prometheus:  http://EC2_IP:30090
Grafana:     http://EC2_IP:30300
```

---

## 🔐 Important Credentials

### Database
- User: `estate_user`
- Password: `estate_password`
- Root Password: `root`
- Database: `estateflow`

### Grafana
- Username: `admin`
- Password: `admin`

### Docker Registry
- Set your Docker Hub credentials in Jenkins

### GitHub
- Add GitHub Personal Access Token to Jenkins

---

## 🐛 DEBUGGING COMMANDS

### Docker Compose
```bash
# View logs
docker-compose logs -f backend
docker-compose logs -f mysql

# Execute command in container
docker-compose exec backend npm test

# Check health
docker-compose ps

# Stop & remove all
docker-compose down
```

### Kubernetes
```bash
# View all resources
kubectl get all -n estate

# View pod logs
kubectl logs deployment/backend-deployment -n estate -f

# Execute into pod
kubectl exec -it <pod-name> -n estate -- /bin/sh

# Describe pod for issues
kubectl describe pod <pod-name> -n estate

# Check persistent volumes
kubectl get pvc -n estate

# Check services
kubectl get svc -n estate

# Port forward to test locally
kubectl port-forward svc/backend-service 5000:5000 -n estate
```

### Jenkins
```bash
# View Jenkins logs
docker logs jenkins

# Rebuild job
curl -X POST http://JENKINS_IP:8080/job/estate-flow-pipeline/build

# Get build logs
curl http://JENKINS_IP:8080/job/estate-flow-pipeline/1/consoleText
```

---

## 📝 CONFIGURATION FILES

### Namespace Isolation
All resources are in the `estate` namespace. To switch context:
```bash
kubectl config set-context --current --namespace=estate
```

### Update Database Credentials
Edit file: `k8s/secrets/db-secret.yaml`
```bash
# Update and apply
kubectl apply -f k8s/secrets/db-secret.yaml
```

### Update Backend Configuration
Edit file: `k8s/configmaps/backend-config.yaml`
```bash
kubectl apply -f k8s/configmaps/backend-config.yaml
```

### Update Prometheus Config
Edit file: `k8s/monitoring/prometheus-config.yaml`
```bash
kubectl apply -f k8s/monitoring/prometheus-config.yaml
# Restart prometheus
kubectl rollout restart deployment/prometheus-deployment -n estate
```

---

## 🔄 PIPELINE TRIGGER

### GitHub Webhook (Automatic)
```bash
# 1. Configure in GitHub Settings → Webhooks
# 2. URL: http://JENKINS_IP:8080/github-webhook/
# 3. Events: Push events
# 4. Make a commit and push
# Pipeline automatically triggers
```

### Manual Trigger
```bash
# Jenkins UI: Click "Build Now"
# OR via API
curl -X POST http://JENKINS_IP:8080/job/estate-flow-pipeline/build
```

---

## 🧹 CLEANUP

### Remove Local Containers
```bash
docker-compose down -v
docker system prune -a
```

### Remove Kubernetes Deployment
```bash
chmod +x scripts/cleanup-k8s.sh && ./scripts/cleanup-k8s.sh
```

### Full AWS Cleanup
```bash
# Delete EC2 instance via AWS Console or CLI
# All resources created by deployment will be cleaned up
```

---

## 📊 MONITORING

### Prometheus Queries
```
# CPU usage
container_cpu_usage_seconds_total

# Memory usage
container_memory_usage_bytes

# Pod restart count
kube_pod_container_status_restarts_total

# HTTP request latency
http_request_duration_seconds
```

### Grafana Dashboard
1. Add Prometheus as data source (http://prometheus:9090)
2. Import dashboard ID: 7249 (Kubernetes Cluster Monitoring)
3. Select Prometheus data source

---

## 🆘 COMMON ISSUES

### "Connection refused: MySQL"
```bash
# Check MySQL pod
kubectl describe pod -l app=mysql -n estate
kubectl logs deployment/mysql-deployment -n estate

# Wait for MySQL readiness probe
kubectl get pod -l app=mysql -n estate -o jsonpath='{.items[0].status.containerStatuses[0].ready}'
```

### "ImagePullBackOff"
```bash
# Create registry secret
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=USERNAME \
  --docker-password=PASSWORD \
  -n estate

# Verify secret
kubectl get secret regcred -n estate
```

### "CrashLoopBackOff"
```bash
# Check pod logs
kubectl logs <pod-name> -n estate --previous

# Describe pod
kubectl describe pod <pod-name> -n estate

# Check resource limits
kubectl get pod <pod-name> -n estate -o json | grep -A 5 "resources"
```

### "Pending PVC"
```bash
# Check storage class
kubectl get storageclass

# Describe PVC
kubectl describe pvc mysql-pvc -n estate

# For local testing, use hostPath (not production-ready)
```

---

## ✅ VERIFICATION CHECKLIST

After deployment, verify:

- [ ] `kubectl get pods -n estate` - All pods Running
- [ ] `kubectl get svc -n estate` - All services created
- [ ] `kubectl get pvc -n estate` - PVC bound
- [ ] Test backend: `curl http://NODE_IP:30000/api/properties`
- [ ] Test frontend: `curl http://NODE_IP:30080` returns HTML
- [ ] Test database: `kubectl exec mysql-pod -n estate -- mysql -u estate_user -p`
- [ ] Prometheus running: `curl http://NODE_IP:30090/-/healthy`
- [ ] Grafana accessible: `curl http://NODE_IP:30300/api/health`

---

**Last Updated**: May 2026
