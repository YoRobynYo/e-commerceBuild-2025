# Maiway - E-commerce Platform

A modern, full-stack e-commerce platform built with Electron (frontend) and FastAPI (backend), featuring AI-powered customer support and automated workflows.

## 🏗️ Architecture

- **Frontend**: Electron app with modern web technologies
- **Backend**: FastAPI with PostgreSQL database
- **AI Integration**: LangChain with OpenAI for customer support
- **Payments**: Stripe integration
- **Deployment**: Docker containerization

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- Python 3.11+
- Docker (optional)
- Git

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Maiway-582435
   ```

2. **Run the setup script**
   ```bash
   ./scripts/dev-setup.sh
   ```

3. **Configure environment variables**
   ```bash
   # Edit backend environment file
   nano maiway/backend/e-commerceBuild-2025/.env
   ```

4. **Start development servers**
   ```bash
   # Start both frontend and backend
   ./scripts/dev-full.sh
   
   # Or start individually
   ./scripts/dev-frontend.sh  # Frontend only
   ./scripts/dev-backend.sh   # Backend only
   ```

## 📦 Build System

### Frontend Build

The frontend uses Webpack for bundling and Electron Builder for packaging:

```bash
# Development
npm run dev                    # Start with hot reload
npm run build:css:watch       # Watch CSS changes
npm run build:js:watch        # Watch JS changes

# Production
npm run build                 # Build all assets
npm run dist                  # Create distributable packages
npm run pack                  # Package without distribution
```

**Available scripts:**
- `dev` - Development mode with hot reload
- `build` - Production build
- `build:css` - Compile SCSS to CSS
- `build:js` - Bundle JavaScript with Webpack
- `build:electron` - Package Electron app
- `test` - Run tests
- `lint` - Code linting
- `clean` - Clean build artifacts

### Backend Build

The backend uses Docker for containerization and includes comprehensive tooling:

```bash
# Development
make dev                      # Start development server
make test                     # Run tests
make lint                     # Code linting
make format                   # Code formatting

# Docker
make docker-build            # Build Docker image
make docker-run              # Run with Docker Compose
make docker-dev              # Development with Docker

# Database
make db-migrate              # Run database migrations
make db-reset                # Reset database
```

## 🐳 Docker Deployment

### Development with Docker

```bash
cd maiway/backend/e-commerceBuild-2025
docker-compose -f docker-compose.dev.yml up
```

### Production with Docker

```bash
cd maiway/backend/e-commerceBuild-2025
docker-compose up -d
```

## 🧪 Testing

### Frontend Tests
```bash
cd maiway
npm test                     # Run Jest tests
npm run test:coverage        # Run with coverage
```

### Backend Tests
```bash
cd maiway/backend/e-commerceBuild-2025
make test                    # Run pytest tests
pytest --cov=app            # Run with coverage
```

## 🔧 Configuration

### Environment Variables

**Backend (.env):**
```env
DATABASE_URL=sqlite:///./dev.db
JWT_SECRET=your-secret-key
FRONTEND_URL=http://localhost:5173
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
OPENAI_API_KEY=sk-xxx
SENDGRID_API_KEY=SG.xxx
FROM_EMAIL=no-reply@maiway.com
```

### Build Configuration

**Frontend (webpack.config.js):**
- Entry points for main process, preload, and renderer
- Asset optimization and minification
- Source maps for debugging
- Hot reload for development

**Backend (Dockerfile):**
- Multi-stage build for optimization
- Security hardening with non-root user
- Health checks and proper signal handling
- Production-ready configuration

## 📊 Performance Optimizations

### Frontend
- **Code Splitting**: Automatic vendor chunk splitting
- **Tree Shaking**: Dead code elimination
- **Minification**: Production builds are minified
- **Source Maps**: Debug-friendly source maps
- **Asset Optimization**: Image and font optimization

### Backend
- **Multi-stage Docker**: Smaller production images
- **Connection Pooling**: Database connection optimization
- **Caching**: Redis integration for session management
- **Async Processing**: Celery for background tasks
- **Security**: Bandit and Safety security checks

## 🚀 Deployment

### CI/CD Pipeline

The project includes a comprehensive GitHub Actions workflow:

1. **Frontend Tests**: Linting, testing, and building
2. **Backend Tests**: Linting, security checks, and testing
3. **Integration Tests**: End-to-end testing
4. **Docker Build**: Multi-platform image building
5. **Deployment**: Automated staging and production deployment

### Production Deployment

1. **Build Docker images**
   ```bash
   docker build -t maiway-backend ./maiway/backend/e-commerceBuild-2025
   ```

2. **Deploy with Docker Compose**
   ```bash
   docker-compose up -d
   ```

3. **Monitor deployment**
   ```bash
   docker-compose logs -f
   ```

## 🛠️ Development Tools

### Code Quality
- **ESLint**: JavaScript linting
- **Black**: Python code formatting
- **Flake8**: Python linting
- **Bandit**: Security linting
- **Safety**: Dependency vulnerability checking

### Testing
- **Jest**: Frontend testing framework
- **Pytest**: Backend testing framework
- **Coverage**: Code coverage reporting

### Build Tools
- **Webpack**: Frontend bundling
- **Sass**: CSS preprocessing
- **Electron Builder**: App packaging
- **Docker**: Containerization

## 📁 Project Structure

```
Maiway-582435/
├── maiway/                          # Frontend (Electron)
│   ├── css/                         # Stylesheets
│   ├── js/                          # JavaScript modules
│   ├── pages/                       # HTML pages
│   ├── public/                      # Static assets
│   ├── dist/                        # Build output
│   ├── webpack.config.js            # Webpack configuration
│   └── package.json                 # Frontend dependencies
├── maiway/backend/e-commerceBuild-2025/  # Backend (FastAPI)
│   ├── app/                         # Application code
│   ├── tests/                       # Test files
│   ├── Dockerfile                   # Production Docker image
│   ├── docker-compose.yml           # Production Docker setup
│   ├── docker-compose.dev.yml       # Development Docker setup
│   ├── Makefile                     # Build automation
│   └── requirements.txt             # Python dependencies
├── scripts/                         # Development scripts
└── .github/workflows/               # CI/CD pipelines
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the CI/CD logs for build issues