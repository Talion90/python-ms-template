#!/bin/bash

# Python Microservice Template Setup Script
# This script customizes the template for a new project

set -e

echo "🚀 Python Microservice Template Setup"
echo "======================================"

# Get project details
read -p "Enter project name (e.g., user-service): " PROJECT_NAME
read -p "Enter project description: " PROJECT_DESCRIPTION
read -p "Enter your GitHub username/organization: " GITHUB_USER

# Validate inputs
if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_DESCRIPTION" ] || [ -z "$GITHUB_USER" ]; then
    echo "❌ Error: All fields are required!"
    exit 1
fi

echo ""
echo "📝 Customizing project..."

# Update pyproject.toml
sed -i.bak "s/python-ms-template/$PROJECT_NAME/g" pyproject.toml
sed -i.bak "s/A template for a microservice based on python/$PROJECT_DESCRIPTION/g" pyproject.toml

# Update app/__init__.py if it exists
if [ -f "app/__init__.py" ]; then
    sed -i.bak "s/python-ms-template/$PROJECT_NAME/g" app/__init__.py
    sed -i.bak "s/A template for a microservice based on python/$PROJECT_DESCRIPTION/g" app/__init__.py
fi

# Update Makefile
sed -i.bak "s/python-ms-template/$PROJECT_NAME/g" Makefile

# Update Docker related files
sed -i.bak "s/python-ms-template/$PROJECT_NAME/g" Dockerfile
sed -i.bak "s/python-ms-template/$PROJECT_NAME/g" .github/workflows/ci.yml

# Update CI workflow for new repository
sed -i.bak "s/ghcr.io\/\${{ github.repository_owner }}\/python-ms-template/ghcr.io\/$GITHUB_USER\/$PROJECT_NAME/g" .github/workflows/ci.yml

# Update README
cat > README.md << EOF
# $PROJECT_NAME

$PROJECT_DESCRIPTION

## 🚀 Quick Start

\`\`\`bash
# Install dependencies
make dependencies

# Install pre-commit hooks
make pre-commit-install

# Run the application
make run-dev

# Run tests
make test

# Check code quality
make lint
\`\`\`

## 📋 Available Commands

Run \`make help\` to see all available commands.

## 🐳 Docker

\`\`\`bash
# Development
make build-dev && make run-dev

# Testing
make build-test && make run-test

# Production
make build-prod && make run-prod
\`\`\`

## 📊 Health Check

\`\`\`bash
# Check application health
python main.py health

# Show configuration
python main.py config
\`\`\`

Generated from [python-ms-template](https://github.com/your-username/python-ms-template)
EOF

# Clean up backup files
find . -name "*.bak" -delete

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "feat: initial project setup from template

- Project: $PROJECT_NAME
- Description: $PROJECT_DESCRIPTION
- Generated from python-ms-template"
fi

echo ""
echo "✅ Project setup complete!"
echo ""
echo "Next steps:"
echo "1. Update dependencies: make dependencies"
echo "2. Install pre-commit: make pre-commit-install"
echo "3. Run tests: make test"
echo "4. Start development: make run-dev"
echo ""
echo "�� Happy coding!"
EOF
