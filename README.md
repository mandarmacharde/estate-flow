# EstateFlow

EstateFlow is a portable, full-stack application designed to run seamlessly in both local Docker Compose environments and Kubernetes clusters.

## Architecture

- **Frontend:** Static SPA served by Nginx (runs as a non-root user).
- **Backend:** Node.js API service.
- **Database:** MySQL.
- **Monitoring:** Prometheus + Grafana.

---

## 🚀 Running Locally with Docker Compose

We provide a convenient helper script (`./scripts/start.sh`) to manage the Docker Compose lifecycle, or you can use standard `docker compose` commands.

### Prerequisites
- Docker and Docker Compose installed.

### Quick Start

1. **Copy the environment file (if you haven't already):**
   ```bash
   cp .env.example .env
   ```

2. **Start all services:**
   ```bash
   ./scripts/start.sh start
   ```
   *(Alternatively: `docker compose up -d --build`)*

3. **Access the application:**
   - **Frontend:** [http://localhost:8080](http://localhost:8080)
   - **Backend API:** [http://localhost:5001/api/health](http://localhost:5001/api/health)
   - **Prometheus:** [http://localhost:9091](http://localhost:9091)
   - **Grafana:** [http://localhost:3002](http://localhost:3002) *(Default login: admin / admin123)*

### Other Helper Commands

- `./scripts/start.sh stop` - Stop all containers
- `./scripts/start.sh restart` - Restart all containers
- `./scripts/start.sh logs` - View combined logs for all services
- `./scripts/start.sh status` - Check the status of running containers
- `./scripts/start.sh clean` - **WARNING**: Stops containers and removes all volumes (deletes database data).

---

## ☸️ Running in Kubernetes (K8s)

The `k8s/` directory contains all the necessary manifests to deploy EstateFlow into a Kubernetes cluster. The components are separated logically.

### Prerequisites
- A running Kubernetes cluster (e.g., Minikube, Docker Desktop K8s, EKS, GKE).
- `kubectl` configured to interact with your cluster.

### Deployment Steps

1. **Create the Namespace:**
   Apply the namespace first so subsequent resources have a target.
   ```bash
   kubectl apply -f k8s/namespaces/
   ```

2. **Apply Configuration and Secrets:**
   ```bash
   kubectl apply -f k8s/configmaps/
   kubectl apply -f k8s/secrets/
   ```
   *(Note: For production, ensure your secrets are properly encrypted or managed via a Secret Store provider, rather than plain yaml).*

3. **Deploy the Database:**
   Wait for the MySQL pod to be in the `Running` state before proceeding.
   ```bash
   kubectl apply -f k8s/mysql/
   kubectl get pods -n estate -w
   ```

4. **Deploy the Application:**
   ```bash
   kubectl apply -f k8s/backend/
   kubectl apply -f k8s/frontend/
   ```

5. **Deploy Monitoring (Optional):**
   ```bash
   kubectl apply -f k8s/monitoring/
   ```

### Accessing the Application in K8s

Depending on your cluster setup, you may need to port-forward to access the services locally if you aren't using an Ingress controller or LoadBalancer:

- **Frontend:**
  ```bash
  kubectl port-forward svc/frontend-service -n estate 8080:8080
  ```
  *(Then visit http://localhost:8080)*

- **Backend:**
  ```bash
  kubectl port-forward svc/backend-service -n estate 5000:5000
  ```

### Teardown

To remove all EstateFlow resources from your cluster, you can simply delete the namespace:
```bash
kubectl delete -f k8s/namespaces/namespace.yaml
```
*(Warning: This will destroy all pods, services, and PVCs in the `estate` namespace).*
