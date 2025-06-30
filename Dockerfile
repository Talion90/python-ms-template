# Use Python 3.13 alpine image as base
FROM python:3.13-alpine AS base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apk add --no-cache curl

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy uv configuration files
COPY pyproject.toml uv.lock ./

# Development stage
FROM base AS development

# Install development dependencies
RUN uv sync --dev

# Copy source code
COPY . .

# Set development environment
ENV ENVIRONMENT=development

# Expose port for development server
EXPOSE 8000

# Default command for development
CMD ["uv", "run", "python", "main.py"]

# Testing stage
FROM base AS testing

# Install dependencies including test dependencies
RUN uv sync --dev

# Copy source code
COPY . .

# Set test environment
ENV ENVIRONMENT=testing

# Run tests by default
CMD ["uv", "run", "pytest", "-v"]

# Production build stage
FROM base AS build-production

# Install only production dependencies
RUN uv sync --no-dev

# Production stage
FROM python:3.13-alpine AS production

# Set environment variables for production
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ENVIRONMENT=production

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser

# Set working directory
WORKDIR /app

# Copy uv from base stage
COPY --from=base /usr/local/bin/uv /usr/local/bin/uv
COPY --from=base /usr/local/lib/python*/site-packages /usr/local/lib/python*/site-packages

# Copy virtual environment from build stage
COPY --from=build-production /app/.venv /app/.venv

# Copy only necessary application files
COPY main.py ./
COPY pyproject.toml ./

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Add virtual environment to PATH
ENV PATH="/app/.venv/bin:$PATH"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Default command for production
CMD ["python", "main.py"]
