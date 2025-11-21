#!/bin/bash
# IPMAS Deployment Script
# Quick deployment helper script

set -e

echo "🚀 IPMAS Deployment Helper"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env files exist
check_env_files() {
    echo "Checking environment files..."
    
    if [ ! -f "backend/.env" ]; then
        echo -e "${YELLOW}⚠️  backend/.env not found${NC}"
        echo "Creating from template..."
        if [ -f "backend/env" ]; then
            cp backend/env backend/.env
            echo -e "${GREEN}✓ Created backend/.env from template${NC}"
            echo -e "${YELLOW}⚠️  Please edit backend/.env with your production values${NC}"
        else
            echo -e "${RED}✗ backend/env template not found${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}✓ backend/.env exists${NC}"
    fi
}

# Check Docker
check_docker() {
    echo ""
    echo "Checking Docker installation..."
    
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓ Docker is installed${NC}"
        docker --version
    else
        echo -e "${RED}✗ Docker is not installed${NC}"
        echo "Please install Docker: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    if command -v docker-compose &> /dev/null; then
        echo -e "${GREEN}✓ Docker Compose is installed${NC}"
        docker-compose --version
    else
        echo -e "${RED}✗ Docker Compose is not installed${NC}"
        return 1
    fi
}

# Deploy with Docker
deploy_docker() {
    echo ""
    echo "Deploying with Docker Compose..."
    
    if [ -f "docker-compose.prod.yml" ]; then
        echo "Using docker-compose.prod.yml"
        docker-compose -f docker-compose.prod.yml up -d --build
    else
        echo "Using docker-compose.yml"
        docker-compose up -d --build
    fi
    
    echo ""
    echo -e "${GREEN}✓ Deployment started${NC}"
    echo ""
    echo "View logs with: docker-compose logs -f"
    echo "Stop with: docker-compose down"
}

# Main menu
main() {
    echo "Select deployment method:"
    echo "1) Docker Compose (Local/Server)"
    echo "2) Check environment setup"
    echo "3) View deployment guides"
    echo "4) Exit"
    echo ""
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1)
            check_docker
            check_env_files
            deploy_docker
            ;;
        2)
            check_env_files
            check_docker
            ;;
        3)
            echo ""
            echo "📚 Deployment Guides:"
            echo "- Quick Start: DEPLOYMENT_QUICK_START.md"
            echo "- Full Guide: DEPLOYMENT_GUIDE.md"
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main

