#!/bin/bash
set -e

# Local Docker Compose Deployment
# This script sets up the complete application locally using Docker Compose

echo "========================================="
echo "🚀 Local Docker Compose Deployment"
echo "========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created. Please update with your values if needed."
fi

# Build images
echo "Building Docker images..."
docker-compose build

# Start services
echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Display service status
echo ""
echo "========================================="
echo "✅ Deployment Complete!"
echo "========================================="
echo ""
echo "📊 Service URLs:"
echo "  Frontend:    http://localhost:8080"
echo "  Backend:     http://localhost:5000"
echo "  Prometheus:  http://localhost:9090"
echo "  Grafana:     http://localhost:3000 (admin:admin)"
echo ""

# Show container status
echo "Container Status:"
docker-compose ps

echo ""
echo "🛑 To stop the services, run: docker-compose down"
echo "📝 To view logs: docker-compose logs -f [service-name]"
