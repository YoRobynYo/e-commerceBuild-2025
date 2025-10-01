#!/bin/bash
set -euo pipefail

# Production deployment script for Maiway
# Usage: ./scripts/deploy-production.sh [environment]

ENVIRONMENT=${1:-production}
BACKUP_DIR="/backups/maiway"
LOG_FILE="/var/log/maiway-deploy.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1" | tee -a "$LOG_FILE"
}

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if running as root or with sudo
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. Consider using a non-root user with sudo privileges."
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "maiway/backend/e-commerceBuild-2025/docker-compose.prod.yml" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Backup current deployment
backup_current() {
    print_info "Creating backup of current deployment..."
    
    # Create backup directory
    sudo mkdir -p "$BACKUP_DIR"
    
    # Backup database
    if docker-compose -f maiway/backend/e-commerceBuild-2025/docker-compose.prod.yml ps db | grep -q "Up"; then
        print_info "Backing up database..."
        docker-compose -f maiway/backend/e-commerceBuild-2025/docker-compose.prod.yml exec -T db pg_dump -U maiway_user maiway_prod > "$BACKUP_DIR/db_backup_$(date +%Y%m%d_%H%M%S).sql"
        print_status "Database backup completed"
    else
        print_warning "Database not running, skipping backup"
    fi
    
    # Backup application data
    if [ -d "maiway/backend/e-commerceBuild-2025/logs" ]; then
        cp -r maiway/backend/e-commerceBuild-2025/logs "$BACKUP_DIR/logs_backup_$(date +%Y%m%d_%H%M%S)"
        print_status "Logs backup completed"
    fi
}

# Pull latest code
pull_latest_code() {
    print_info "Pulling latest code..."
    
    # Check if we're in a git repository
    if [ -d ".git" ]; then
        git fetch origin
        git checkout main
        git pull origin main
        print_status "Code updated successfully"
    else
        print_warning "Not a git repository, skipping code update"
    fi
}

# Build and deploy
deploy_application() {
    print_info "Building and deploying application..."
    
    cd maiway/backend/e-commerceBuild-2025
    
    # Build new images
    print_info "Building Docker images..."
    docker-compose -f docker-compose.prod.yml build --no-cache
    
    # Stop current services
    print_info "Stopping current services..."
    docker-compose -f docker-compose.prod.yml down
    
    # Start new services
    print_info "Starting new services..."
    docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for services to be healthy
    print_info "Waiting for services to be healthy..."
    sleep 30
    
    # Check service health
    if docker-compose -f docker-compose.prod.yml ps | grep -q "unhealthy"; then
        print_error "Some services are unhealthy"
        docker-compose -f docker-compose.prod.yml logs
        exit 1
    fi
    
    print_status "Application deployed successfully"
    cd ../..
}

# Run database migrations
run_migrations() {
    print_info "Running database migrations..."
    
    cd maiway/backend/e-commerceBuild-2025
    
    # Wait for database to be ready
    sleep 10
    
    # Run migrations
    docker-compose -f docker-compose.prod.yml exec backend alembic upgrade head
    
    print_status "Database migrations completed"
    cd ../..
}

# Health check
health_check() {
    print_info "Performing health check..."
    
    # Check if backend is responding
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        print_status "Backend health check passed"
    else
        print_error "Backend health check failed"
        exit 1
    fi
    
    # Check if database is accessible
    cd maiway/backend/e-commerceBuild-2025
    if docker-compose -f docker-compose.prod.yml exec -T db pg_isready -U maiway_user; then
        print_status "Database health check passed"
    else
        print_error "Database health check failed"
        exit 1
    fi
    cd ../..
}

# Cleanup old images
cleanup() {
    print_info "Cleaning up old Docker images..."
    
    # Remove unused images
    docker image prune -f
    
    # Remove old backups (keep last 7 days)
    find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
    find "$BACKUP_DIR" -name "logs_backup_*" -mtime +7 -exec rm -rf {} \;
    
    print_status "Cleanup completed"
}

# Main deployment function
main() {
    log "Starting production deployment for environment: $ENVIRONMENT"
    
    check_permissions
    check_prerequisites
    backup_current
    pull_latest_code
    deploy_application
    run_migrations
    health_check
    cleanup
    
    print_status "Production deployment completed successfully!"
    print_info "Application is available at: https://your-domain.com"
    print_info "API documentation: https://your-domain.com/docs"
    
    log "Production deployment completed successfully"
}

# Error handling
trap 'print_error "Deployment failed at line $LINENO"' ERR

# Run main function
main "$@"