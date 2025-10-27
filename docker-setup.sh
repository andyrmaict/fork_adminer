#!/bin/bash

# Adminer Docker Setup Script
# This script helps you quickly set up and manage Adminer in Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

# Function to start Adminer
start_adminer() {
    print_status "Starting Adminer..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_success "Adminer is now running!"
        print_status "Access Adminer at: http://localhost:8060"
        print_status "Access Adminer Editor at: http://localhost:8060/editor"
    else
        print_error "Failed to start Adminer"
        exit 1
    fi
}

# Function to stop Adminer
stop_adminer() {
    print_status "Stopping Adminer..."
    docker-compose down
    print_success "Adminer stopped."
}

# Function to restart Adminer
restart_adminer() {
    print_status "Restarting Adminer..."
    docker-compose down
    docker-compose up -d
    print_success "Adminer restarted!"
}

# Function to show logs
show_logs() {
    print_status "Showing Adminer logs..."
    docker-compose logs -f adminer
}

# Function to show status
show_status() {
    print_status "Adminer container status:"
    docker-compose ps
}

# Function to rebuild
rebuild() {
    print_status "Rebuilding Adminer..."
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    print_success "Adminer rebuilt and started!"
}

# Function to enable database services
enable_databases() {
    print_warning "To enable database services, uncomment the database sections in docker-compose.yml"
    print_status "Available databases: MySQL, PostgreSQL"
    print_status "Edit docker-compose.yml and remove the # comments from the desired database service"
}

# Function to show help
show_help() {
    echo "Adminer Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start       Start Adminer"
    echo "  stop        Stop Adminer"
    echo "  restart     Restart Adminer"
    echo "  status      Show container status"
    echo "  logs        Show container logs"
    echo "  rebuild     Rebuild and restart Adminer"
    echo "  databases   Show info about enabling database services"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start    # Start Adminer"
    echo "  $0 logs     # View logs"
    echo "  $0 rebuild  # Rebuild from scratch"
}

# Main script logic
case "${1:-}" in
    start)
        check_docker
        start_adminer
        ;;
    stop)
        check_docker
        stop_adminer
        ;;
    restart)
        check_docker
        restart_adminer
        ;;
    status)
        check_docker
        show_status
        ;;
    logs)
        check_docker
        show_logs
        ;;
    rebuild)
        check_docker
        rebuild
        ;;
    databases)
        enable_databases
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        print_status "No command specified. Starting Adminer..."
        check_docker
        start_adminer
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac