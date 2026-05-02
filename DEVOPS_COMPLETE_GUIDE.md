# 🔧 EstateFlow DevOps Complete Guide

**Last Updated:** May 1, 2026  
**Status:** ✅ Production-Ready

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Port Management](#port-management)
3. [Service Communication](#service-communication)
4. [Environment Setup](#environment-setup)
5. [Docker Compose Details](#docker-compose-details)
6. [Debugging Guide](#debugging-guide)
7. [Performance Tuning](#performance-tuning)
8. [Scaling Considerations](#scaling-considerations)

---

## Architecture Overview

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network: estate_network           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │   Frontend       │         │   Monitoring     │         │
│  │  (Nginx:80)      │         │                  │         │
│  │                  │         │  ┌────────────┐  │         │
│  │  • Serves HTML   │         │  │ Prometheus │  │         │
│  │  • Proxies /api/ ├────────────┤  :9090    │  │         │
│  │  • Routes SPA    │         │  └────────────┘  │         │
│  │                  │         │                  │         │
│  │ Published:       │         │  ┌────────────┐  │         │
│  │ :8080            │         │  │  Grafana   │  │         │
│  └────────┬─────────┘         │  │   :3000   │  │         │
│           │                   │  └────────────┘  │         │
│           │                   └────────┬─────────┘         │
│           │                            │                   │
│  ┌────────▼──────────────────────────────────────┐         │
│  │          Backend Service                      │         │
│  │       (Node.js Express: 5000)                │         │
│  │                                              │         │
│  │  • API endpoints (/api/*)                   │         │
│  │  • Health check (/api/health)              │         │
│  │  • Database connection pool                │         │
│  │  • CORS configured                         │         │
│  │                                              │         │
│  │  Published:                                 │         │
│  │  :5001                                      │         │
│  └────────┬────────────────────────────────────┘         │
│           │                                              │
│  ┌────────▼──────────────────────────────────────┐         │
│  │        MySQL Database                         │         │
│  │       (MySQL 8.0: 3306)                      │         │
│  │                                              │         │
│  │  • User: estate_user                        │         │
│  │  • Database: estateflow                     │         │
│  │  • Persisted: mysql_data volume             │         │
│  │                                              │         │
│  │  Published:                                 │         │
│  │  :3307                                      │         │
│  └───────────────────────────────────────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

External Access:
  Browser → :8080 (Frontend)
  Dashboard → :3002 (Grafana)
  Metrics → :9091 (Prometheus)
  API Debug → :5001 (Backend - internal use only)
  DB Debug → :3307 (MySQL - internal use only)
```

---

## Port Management

### Default Port Mapping

| Service | Container Port | Host Port | Environment Variable | Purpose |
|---------|---|---|---|---|
| **Frontend** | 80 | 8080 | `FRONTEND_PORT` | User-facing web app |
| **Backend** | 5000 | 5001 | `BACKEND_PORT` | API server (debug) |
| **MySQL** | 3306 | 3307 | `DB_PORT` | Database (debug) |
| **Prometheus** | 9090 | 9091 | `PROMETHEUS_PORT` | Metrics collection |
| **Grafana** | 3000 | 3002 | `GRAFANA_PORT` | Dashboards |

### Why Different Host Ports?

- Container ports are **fixed** (hardcoded in application code)
- Host ports are **flexible** (mapped via docker-compose.yml)
- This allows multiple projects to run without conflicts

### Port Conflict Resolution

**Check if port is in use:**

```bash
# macOS/Linux
lsof -i :8080

# Windows (PowerShell)
netstat -ano | findstr :8080

# Docker (universal)
docker ps --format "{{.Names}}\t{{.Ports}}"
```

**Solution:**

```bash
# Edit .env
FRONTEND_PORT=9000
BACKEND_PORT=5555
DB_PORT=3399

# Restart
docker compose down
docker compose up -d --build
```

---

## Service Communication

### Internal (Docker Network)

```javascript
// ✅ Backend calls Database (CORRECT)
const db = mysql.createPool({
    host: 'mysql',           // Service name (not localhost)
    port: 3306,              // Container port (not host port)
    user: 'estate_user'
});

// ✅ Frontend calls Backend (CORRECT)
fetch('/api/properties')     // Via Nginx proxy
// Nginx translates to: http://backend:5000/api/properties
```

### External (Host Machine)

```bash
# ✅ Access Frontend
http://localhost:8080

# ✅ Debug Backend API
http://localhost:5001/api/properties
http://localhost:5001/api/health

# ✅ Access Database (MySQL CLI)
mysql -h localhost -P 3307 -u estate_user -p

# ✅ Access Prometheus
http://localhost:9091

# ✅ Access Grafana
http://localhost:3002
```

### Key Rules

| Scenario | Use | Don't Use | Why |
|----------|-----|----------|-----|
| Frontend → Backend | `/api/...` | `http://localhost:5000` | Nginx handles proxy |
| Backend → Database | `mysql:3306` | `localhost:3307` | Internal network |
| External → Frontend | `localhost:8080` | `0.0.0.0:8080` | Host port mapping |
| External → Backend | `localhost:5001` | Direct access | Debug only |

---

## Environment Setup

### Create from Template

```bash
# Copy example to .env
cp .env.example .env

# Edit for your environment
nano .env  # or use any editor
```

### Auto-Generated .env

If `.env` doesn't exist, `./scripts/start.sh` auto-creates it:

```bash
./scripts/start.sh start
# → Creates .env from .env.example automatically
```

### Environment Variables Reference

```env
# ===== PORTS =====
FRONTEND_PORT=8080          # Change if port in use
BACKEND_PORT=5001           # For debugging API
DB_PORT=3307                # For debugging DB
PROMETHEUS_PORT=9091        # Metrics UI
GRAFANA_PORT=3002           # Dashboards UI

# ===== DATABASE =====
DB_HOST=mysql               # Service name (DO NOT change)
DB_PORT=3306                # Container port (DO NOT change)
DB_USER=estate_user         # MySQL user
DB_PASSWORD=estate_password # Change for production!
DB_ROOT_PASSWORD=root       # Root password
DB_NAME=estateflow          # Database name

# ===== GRAFANA =====
GRAFANA_PASSWORD=admin123   # Change for production!

# ===== NODE =====
NODE_ENV=production         # production|development
```

### Environment Variable Override

```bash
# Override during startup
export FRONTEND_PORT=9000
export BACKEND_PORT=5555
./scripts/start.sh start

# Or inline
FRONTEND_PORT=9000 ./scripts/start.sh start
```

---

## Docker Compose Details

### Service Startup Order

```yaml
1. mysql               # Starts first
   ↓ (waits for health check)

2. backend             # Waits for mysql
   ↓ (waits for health check)

3. frontend            # Waits for backend
   ↓ (waits for health check)

4. prometheus          # Independent
   ↓

5. grafana             # Waits for prometheus
```

### Health Check Flow

Each service has health checks:

```yaml
healthcheck:
  test: ["CMD", "curl", "http://localhost:PORT/health"]
  interval: 10s        # Check every 10 seconds
  timeout: 5s          # Wait max 5 seconds
  retries: 3           # Fail after 3 retries
  start_period: 15s    # Grace period before first check
```

### Restart Policy

```yaml
restart: unless-stopped  # Restart on crash, NOT on compose down
```

| Policy | Behavior |
|--------|----------|
| `no` | Don't restart |
| `always` | Always restart |
| `unless-stopped` | Restart unless explicitly stopped |
| `on-failure` | Only restart on non-zero exit |

### Network Configuration

```yaml
networks:
  estate_network:      # User-defined bridge network
    # Services can reach each other by name
```

**Test network connectivity:**

```bash
docker exec estate_backend ping mysql
docker exec estate_frontend ping backend
docker network inspect estate_network
```

### Volume Management

```yaml
volumes:
  mysql_data:           # Persists database files
  prometheus_data:      # Persists metrics
  grafana_data:         # Persists dashboards
```

**Inspect volumes:**

```bash
docker volume ls
docker volume inspect estate-flow_mysql_data
docker volume prune  # Remove unused volumes
```

---

## Debugging Guide

### View Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs backend
docker compose logs mysql

# Follow logs (real-time)
docker compose logs -f

# Last 50 lines
docker compose logs --tail=50

# Since specific time
docker compose logs --since 2024-01-01T00:00:00
```

### Execute Commands in Container

```bash
# Bash shell
docker compose exec backend bash

# Run command
docker compose exec backend npm list

# MySQL client
docker compose exec mysql mysql -u estate_user -p

# Curl test
docker compose exec backend curl http://backend:5000/api/health
```

### Check Service Health

```bash
# See health status
docker compose ps

# Column STATUS shows: Up (healthy) or Up (unhealthy)

# Detailed health info
docker inspect estate_backend | grep -A 20 "Health"
```

### Network Debugging

```bash
# List networks
docker network ls

# Inspect network
docker network inspect estate_network

# Test DNS resolution
docker compose exec frontend ping mysql
docker compose exec backend host backend

# Check routing
docker compose exec frontend route -n
```

### Port Debugging

```bash
# Check port mappings
docker compose ps

# Check if port is open
curl http://localhost:8080
curl http://localhost:5001/api/health

# List open ports
docker network inspect estate_network | grep -i ports
```

### Database Debugging

```bash
# Connect to MySQL
docker compose exec mysql mysql -u estate_user -p

# Inside MySQL shell:
USE estateflow;
SHOW TABLES;
SELECT * FROM properties LIMIT 5;
```

### Common Issues

**Backend can't connect to database:**
```bash
# Check MySQL service
docker compose ps mysql

# Check logs
docker compose logs mysql

# Verify credentials in .env
cat .env | grep DB_

# Test connection
docker compose exec backend mysql -h mysql -u estate_user -p
```

**Frontend can't call API:**
```bash
# Check backend health
curl http://localhost:5001/api/health

# Check Nginx proxy configuration
docker compose exec frontend cat /etc/nginx/conf.d/default.conf

# Test proxy directly
docker compose exec frontend curl http://backend:5000/api/properties
```

---

## Performance Tuning

### MySQL Optimization

```yaml
# In docker-compose.yml
environment:
  MYSQL_ROOT_PASSWORD: root
  # Add performance tuning:
  # TZ: UTC
  # MYSQL_CHARSET: utf8mb4
```

### Node.js Optimization

```javascript
// In backend/server.js
const pool = mysql.createPool({
  connectionLimit: 10,      // Connection pool size
  waitForConnections: true,
  queueLimit: 0
});

// Enable clustering for multi-core
const cluster = require('cluster');
const os = require('os');

if (cluster.isMaster) {
  const numCPUs = os.cpus().length;
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
}
```

### Nginx Optimization

```nginx
# Already in nginx.conf
gzip on;
gzip_types text/plain text/css application/javascript;
gzip_min_length 1000;

# Add more:
worker_processes auto;
worker_connections 1024;
keepalive_timeout 65;
```

### Memory Limits

```yaml
# In docker-compose.yml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

---

## Scaling Considerations

### Horizontal Scaling

For multiple backend instances (load balancing):

```yaml
# docker-compose.yml
version: '3.8'

services:
  backend-1:
    build: ./backend
    environment:
      DB_HOST: mysql

  backend-2:
    build: ./backend
    environment:
      DB_HOST: mysql

  # Nginx would round-robin between them
```

### Database Replication

For high availability:

```yaml
services:
  mysql-primary:
    image: mysql:8.0
    environment:
      MYSQL_REPLICATION_MODE: master

  mysql-replica:
    image: mysql:8.0
    environment:
      MYSQL_REPLICATION_MODE: slave
```

### Caching Layer (Redis)

```yaml
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

# Backend connects to redis
```

### Kubernetes Deployment

For container orchestration:

```bash
# Deploy to K8s
kubectl apply -f k8s/
```

---

## Production Checklist

- [ ] Change default passwords (DB, Grafana)
- [ ] Use secrets management (Docker Secrets, Vault)
- [ ] Enable HTTPS/TLS
- [ ] Set up log aggregation
- [ ] Configure monitoring alerts
- [ ] Regular database backups
- [ ] Update Docker images regularly
- [ ] Set resource limits
- [ ] Use private Docker registry
- [ ] Implement health checks
- [ ] Set up CI/CD pipeline
- [ ] Document deployment procedure

---

## Support & Resources

- **Docker Docs**: https://docs.docker.com
- **Docker Compose Docs**: https://docs.docker.com/compose
- **Nginx Docs**: https://nginx.org/en/docs
- **MySQL Docs**: https://dev.mysql.com/doc

---

**Always test in development before production deployment!** 🚀
