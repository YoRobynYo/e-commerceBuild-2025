#!/bin/bash
set -euo pipefail

echo "🚀 Setting up Maiway development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -d "maiway" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Frontend setup
if [ -d "maiway" ]; then
    echo "📦 Setting up frontend..."
    cd maiway
    
    # Install Node.js dependencies
    if [ ! -d "node_modules" ]; then
        print_status "Installing Node.js dependencies..."
        npm install
    else
        print_warning "Node.js dependencies already installed"
    fi
    
    # Create dist directory
    mkdir -p dist/css dist/js dist/assets
    
    # Build CSS
    print_status "Building CSS..."
    npm run build:css
    
    cd ..
fi

# Backend setup
if [ -d "maiway/backend/e-commerceBuild-2025" ]; then
    echo "🐍 Setting up backend..."
    cd maiway/backend/e-commerceBuild-2025
    
    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv .venv
    else
        print_warning "Virtual environment already exists"
    fi
    
    # Activate virtual environment and install dependencies
    print_status "Installing Python dependencies..."
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        cp .env.example .env
        print_warning "Please edit .env file with your API keys"
    fi
    
    # Initialize database
    print_status "Initializing database..."
    python -c "from app.db import init_db; init_db()"
    
    cd ../../..
fi

# Create development scripts
echo "📝 Creating development scripts..."

# Frontend dev script
cat > scripts/dev-frontend.sh << 'EOF'
#!/bin/bash
cd maiway
npm run dev
EOF

# Backend dev script
cat > scripts/dev-backend.sh << 'EOF'
#!/bin/bash
cd maiway/backend/e-commerceBuild-2025
source .venv/bin/activate
uvicorn app.main:app --reload --port 8000
EOF

# Full dev script
cat > scripts/dev-full.sh << 'EOF'
#!/bin/bash
# Start both frontend and backend in development mode
echo "Starting Maiway development environment..."

# Start backend in background
./scripts/dev-backend.sh &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Start frontend
./scripts/dev-frontend.sh &
FRONTEND_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "Stopping development servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    exit 0
}

# Trap Ctrl+C
trap cleanup INT

# Wait for processes
wait
EOF

# Make scripts executable
chmod +x scripts/*.sh

print_status "Development environment setup complete!"
echo ""
echo "Available commands:"
echo "  ./scripts/dev-frontend.sh  - Start frontend development server"
echo "  ./scripts/dev-backend.sh   - Start backend development server"
echo "  ./scripts/dev-full.sh     - Start both frontend and backend"
echo ""
echo "Next steps:"
echo "1. Edit maiway/backend/e-commerceBuild-2025/.env with your API keys"
echo "2. Run ./scripts/dev-full.sh to start development"