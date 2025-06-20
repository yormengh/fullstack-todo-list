3-Tier Application Containerization Guide
This guide provides complete Docker containerization for a React/Node.js/MongoDB application with all necessary configurations, documentation, and testing scripts.

### Project Structure
![Project Structure](./images/Project%20Structure.png)




## Setup Instructions
# Prerequisites

Docker (version 20.10+)
Docker Compose (version 1.29+)
Git
4GB+ available RAM
10GB+ available disk space

## Step-by-Step Setup

Clone the Repository
bashgit clone <your-repository-url>
cd <repository-name>

## Set Up Environment Variables
bashcp .env.example .env
# Edit .env file with your specific configurations
nano .env

Build and Start Services
bash# Build all services
docker-compose build

# Start all services in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

Verify Installation
bash# Check service status
docker-compose ps

# Test endpoints
curl http://localhost:3000  # Frontend
curl http://localhost:5000/health  # Backend health check

## Stop Services
# bash# Stop all services
docker-compose down

# Stop and remove volumes (caution: this deletes data)
docker-compose down -v


## Network and Security Configurations
# Network Architecture

Custom Bridge Network: app-network (172.20.0.0/16)
Service Communication: Internal DNS resolution between containers
Port Mapping: Only necessary ports exposed to host

## Security Measures

1. Database Security

Admin authentication required
No direct external access (only through backend)
Data persistence with Docker volumes
Health checks for availability monitoring


2. Backend Security

Non-root user execution
Environment variable isolation
JWT secret management
CORS configuration
Health check endpoints


3. Frontend Security

Nginx security headers
Gzip compression
Static asset caching
Reverse proxy for API calls



# Exposed Ports

- Frontend: 3000 (HTTP)
- Backend: 5000 (API)
- Database: 27017 (MongoDB - for development only)

## Make the script executable:
- bashchmod +x test-containers.sh
./test-containers.sh
## Troubleshooting Guide
Common Issues and Solutions
1. Port Already in Use
Problem: Error binding to ports 3000, 5000, or 27017
Solution:
bash# Check what's using the port
lsof -i :3000
lsof -i :5000
lsof -i :27017

# Kill processes or change ports in docker-compose.yml
2. Database Connection Fails
Problem: Backend cannot connect to MongoDB
Solutions:
bash# Check database logs
docker-compose logs database

# Verify environment variables
docker exec app-backend env | grep MONGO

# Test connection manually
docker exec app-backend mongosh $MONGODB_URI
3. Frontend Cannot Reach Backend
Problem: API calls failing from frontend
Solutions:

Check REACT_APP_API_URL environment variable
Verify nginx proxy configuration
Test backend endpoint directly: curl http://localhost:5000/health

4. Build Failures
Problem: Docker build fails
Solutions:
bash# Clear Docker cache
docker system prune -a

# Build with no cache
docker-compose build --no-cache

# Check for syntax errors in Dockerfiles
5. Memory Issues
Problem: Containers crashing due to memory
Solutions:
bash# Check container resource usage
docker stats

# Increase Docker memory limit in Docker Desktop
# Add memory limits to docker-compose.yml:
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 512M
6. Volume Permission Issues
Problem: Permission denied errors with volumes
Solutions:
bash# Fix volume permissions
sudo chown -R $USER:$USER ./backend/logs

# Or run containers with specific user
user: "${UID}:${GID}"
Debugging Commands
bash# View all container logs
docker-compose logs

# View specific service logs
docker-compose logs backend -f

# Execute commands in containers
docker exec -it app-backend bash
docker exec -it app-database mongosh

# Inspect container details
docker inspect app-backend

# View container resource usage
docker stats

# Test network connectivity between containers
docker exec app-backend ping database
docker exec app-frontend ping backend

# Check if backend is listening on correct port
docker exec app-backend netstat -tulpn | grep :5000
docker exec app-backend ss -tulpn | grep :5000

# Test backend endpoint from inside container
docker exec app-backend curl -f http://localhost:5000/health
Quick Diagnosis Steps
1. Check Backend Logs:
bashdocker-compose logs backend
2. Verify Backend is Listening:
bash# Check if backend is binding to 0.0.0.0 (not just localhost)
docker exec app-backend netstat -tulpn | grep 5000
3. Test Backend Health Check:
bash# Test from host
curl -v http://localhost:5000/health

# Test from inside backend container
docker exec app-backend curl -v http://localhost:5000/health

# Test from frontend container
docker exec app-frontend curl -v http://backend:5000/health
4. Check Environment Variables:
bashdocker exec app-backend env | grep -E "(PORT|NODE_ENV|MONGODB)"
Health Check Commands
bash# Check all services are healthy
docker-compose ps

# Manual health checks
curl -f http://localhost:3000 || echo "Frontend unhealthy"
curl -f http://localhost:5000/health || echo "Backend unhealthy"
docker exec app-database mongosh --eval "db.adminCommand('ping')" || echo "Database unhealthy"
Performance Optimization Tips

Multi-stage builds for smaller images
Layer caching by copying package.json first
Health checks for better orchestration
Resource limits to prevent container sprawl
Logging configuration to prevent disk filling
Security scanning with docker scan

This containerization setup provides a robust, scalable, and secure foundation for your 3-tier application. All components are properly networked, secured, and monitored for production readiness.
