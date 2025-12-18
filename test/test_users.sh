#!/bin/bash

# Quick Testing Script for Jawara Marketplace
# Usage: ./test_users.sh

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BACKEND_URL="http://localhost/jawara/backend"

echo -e "${YELLOW}=== Jawara Marketplace User Testing ===${NC}\n"

# Test Admin Login
echo -e "${YELLOW}Testing Admin Login...${NC}"
curl -X POST "$BACKEND_URL/auth.php" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "login",
    "email": "admin@jawara.com",
    "password": "Admin@123456"
  }' -s | jq '.' || echo "Error connecting to backend"

echo -e "\n${YELLOW}Testing RT Login...${NC}"
curl -X POST "$BACKEND_URL/auth.php" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "login",
    "email": "rt1@jawara.com",
    "password": "RT@123456"
  }' -s | jq '.' || echo "Error connecting to backend"

echo -e "\n${YELLOW}Testing Warga Login...${NC}"
curl -X POST "$BACKEND_URL/auth.php" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "login",
    "email": "warga1@jawara.com",
    "password": "Warga@123456"
  }' -s | jq '.' || echo "Error connecting to backend"

echo -e "\n${GREEN}Testing complete!${NC}"
