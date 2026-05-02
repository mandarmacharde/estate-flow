#!/bin/bash

# ============================================================================
# EstateFlow One-Command Startup Script
# ============================================================================
# Usage: ./scripts/start.sh [COMMAND]
# Commands:
#   start     - Start containers in detached mode (default)
#   up        - Start containers in attached mode (see logs)
#   stop      - Stop all containers
#   restart   - Restart all containers
#   down      - Stop and remove containers (keep volumes)
#   clean     - Complete cleanup (remove volumes too)
#   logs      - Show live logs from all services
#   status    - Show container status
#   health    - Check health of all services
#
# Environment Variables can be overridden:
#   export FRONTEND_PORT=8080
#   export BACKEND_PORT=5001
#   ./scripts/start.sh start
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default command
COMMAND="${1:-start}"

# Functions
print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is installed"

    if ! docker ps &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    print_success "Docker daemon is running"
}

check_env_file() {
    if [ ! -f "$PROJECT_ROOT/.env" ]; then
        print_info ".env file not found. Creating from .env.example..."
        if [ -f "$PROJECT_ROOT/.env.example" ]; then
            cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
            print_success ".env file created with default values"
        else
            print_error ".env.example not found"
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(cat "$PROJECT_ROOT/.env" | grep -v '#' | xargs)
    fi
}

check_ports() {
    local frontend_port="${FRONTEND_PORT:-8080}"
    local backend_port="${BACKEND_PORT:-5001}"
    local db_port="${DB_PORT:-3307}"
    local prometheus_port="${PROMETHEUS_PORT:-9091}"
    local grafana_port="${GRAFANA_PORT:-3002}"

    print_info "Checking ports..."
    print_info "  Frontend:   http://localhost:$frontend_port"
    print_info "  Backend:    http://localhost:$backend_port"
    print_info "  Database:   localhost:$db_port"
    print_info "  Prometheus: http://localhost:$prometheus_port"
    print_info "  Grafana:    http://localhost:$grafana_port"
}

start_services() {
    print_header "Starting EstateFlow Services"
    check_docker
    check_env_file
    load_env
    check_ports

    cd "$PROJECT_ROOT"

    print_info "Building and starting containers..."
    docker compose up -d --build

    print_success "Services are starting..."
    sleep 3

    # Check health
    print_info "Waiting for services to become healthy..."
    sleep 5
    check_services_health
}

start_services_attached() {
    print_header "Starting EstateFlow Services (Attached Mode)"
    check_docker
    check_env_file
    load_env
    check_ports

    cd "$PROJECT_ROOT"

    print_info "Building and starting containers..."
    docker compose up --build
}

stop_services() {
    print_header "Stopping EstateFlow Services"
    cd "$PROJECT_ROOT"
    
    if docker compose ps | grep -q "estate"; then
        docker compose stop
        print_success "Services stopped"
    else
        print_info "No running services to stop"
    fi
}

restart_services() {
    print_header "Restarting EstateFlow Services"
    stop_services
    sleep 2
    start_services
}

down_services() {
    print_header "Removing EstateFlow Containers"
    cd "$PROJECT_ROOT"
    docker compose down
    print_success "Containers removed (volumes preserved)"
}

clean_services() {
    print_header "Complete Cleanup"
    cd "$PROJECT_ROOT"
    
    print_info "Removing containers and volumes..."
    docker compose down -v
    
    print_success "Complete cleanup done (volumes deleted)"
}

show_logs() {
    print_header "EstateFlow Logs (Press Ctrl+C to exit)"
    cd "$PROJECT_ROOT"
    docker compose logs -f
}

check_services_health() {
    print_header "Health Check"
    load_env

    local frontend_port="${FRONTEND_PORT:-8080}"
    local backend_port="${BACKEND_PORT:-5001}"
    local prometheus_port="${PROMETHEUS_PORT:-9091}"
    local grafana_port="${GRAFANA_PORT:-3002}"

    # Wait for services
    for i in {1..30}; do
        echo -n "."
        sleep 1
    done
    echo ""

    print_info "Frontend: http://localhost:$frontend_port"
    print_info "Backend API: http://localhost:$backend_port/api/health"
    print_info "Prometheus: http://localhost:$prometheus_port"
    print_info "Grafana: http://localhost:$grafana_port (admin/admin123)"

    # Try to check endpoints
    echo ""
    print_info "Testing endpoints..."

    if curl -s -f http://localhost:$frontend_port/ > /dev/null 2>&1; then
        print_success "Frontend is accessible"
    else
        print_error "Frontend is not responding yet (give it a moment)"
    fi

    if curl -s -f http://localhost:$backend_port/api/health > /dev/null 2>&1; then
        print_success "Backend API is healthy"
    else
        print_error "Backend API is not responding yet (give it a moment)"
    fi

    if curl -s -f http://localhost:$prometheus_port/-/healthy > /dev/null 2>&1; then
        print_success "Prometheus is healthy"
    else
        print_error "Prometheus is not responding yet (give it a moment)"
    fi

    if curl -s -f http://localhost:$grafana_port/api/health > /dev/null 2>&1; then
        print_success "Grafana is healthy"
    else
        print_error "Grafana is not responding yet (give it a moment)"
    fi
}

show_status() {
    print_header "Container Status"
    cd "$PROJECT_ROOT"
    docker compose ps
}

# Main command handler
case "$COMMAND" in
    start)
        start_services
        ;;
    up|logs-attached)
        start_services_attached
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    down)
        down_services
        ;;
    clean|cleanup)
        clean_services
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    health|check)
        check_services_health
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        echo ""
        echo "Available commands:"
        echo "  start   - Start containers (default)"
        echo "  up      - Start and show logs"
        echo "  stop    - Stop containers"
        echo "  restart - Restart containers"
        echo "  down    - Remove containers"
        echo "  clean   - Remove containers and volumes"
        echo "  logs    - Show live logs"
        echo "  status  - Show container status"
        echo "  health  - Check service health"
        exit 1
        ;;
esac

print_header "Done! 🎉"
