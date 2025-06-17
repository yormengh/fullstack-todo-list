#!/bin/bash

# Container Testing Script
echo "🧪 Starting container tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local expected_status=$2
    local description=$3
    
    echo -n "Testing $description... "
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" $url)
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (Status: $status_code)"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $status_code)"
        ((TESTS_FAILED++))
    fi
}

# Function to test database connection
test_database() {
    echo -n "Testing database connection... "
    
    if docker exec app-database mongosh --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
    fi
}

# Function to check container status
check_container_status() {
    local container_name=$1
    local service_name=$2
    
    echo -n "Checking $service_name container status... "
    
    if [ "$(docker inspect -f '{{.State.Running}}' $container_name 2>/dev/null)" == "true" ]; then
        echo -e "${GREEN}✓ RUNNING${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ NOT RUNNING${NC}"
        ((TESTS_FAILED++))
    fi
}

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

echo "📋 Container Status Check"
echo "========================"
check_container_status "app-frontend" "Frontend"
check_container_status "app-backend" "Backend"
check_container_status "app-database" "Database"

echo ""
echo "🌐 Endpoint Tests"
echo "================"
test_endpoint "http://localhost:3000" 200 "Frontend (React App)"
test_endpoint "http://localhost:5000/health" 200 "Backend Health Check"

echo ""
echo "🗄️ Database Tests"
echo "================"
test_database

echo ""
echo "🔗 Inter-service Communication Tests"
echo "==================================="

# Test backend can connect to database
echo -n "Testing backend-database communication... "
if docker exec app-backend node -e "
const mongoose = require('mongoose');
mongoose.connect(process.env.MONGODB_URI, {useNewUrlParser: true, useUnifiedTopology: true})
  .then(() => {console.log('Connection successful'); process.exit(0);})
  .catch(() => {console.log('Connection failed'); process.exit(1);});
" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}"
    ((TESTS_FAILED++))
fi

# Test frontend can reach backend
echo -n "Testing frontend-backend communication... "
if docker exec app-frontend wget -q --spider http://backend:5000/health; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}"
    ((TESTS_FAILED++))
fi

echo ""
echo "📊 Test Summary"
echo "=============="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n🎉 ${GREEN}All tests passed! Your containerized application is ready.${NC}"
    exit 0
else
    echo -e "\n⚠️ ${YELLOW}Some tests failed. Please check the logs and configurations.${NC}"
    exit 1
fi
