.PHONY: help build-dev build-test build-prod build-all run-dev run-test run-prod clean start stop add-module remove-module dependencies test test-unit test-at lint format sort format-all lint-fix pre-commit-install pre-commit-run pre-commit-update logs exec

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "Docker Commands:"
	@echo "  build-dev      - Build development image"
	@echo "  build-test     - Build testing image"
	@echo "  build-prod     - Build production image"
	@echo "  build-all      - Build all targets"
	@echo "  run-dev        - Run development container"
	@echo "  run-test       - Run testing container"
	@echo "  run-prod       - Run production container"
	@echo "  clean          - Remove all images"
	@echo ""
	@echo "Application Commands:"
	@echo "  start          - Start production container"
	@echo "  stop           - Stop production container"
	@echo "  logs           - Show container logs"
	@echo "  exec           - Execute shell in container"
	@echo ""
	@echo "Development Commands:"
	@echo "  dependencies      - Install/sync dependencies"
	@echo "  add-module        - Add new module/dependency"
	@echo "  remove-module     - Remove module/dependency"
	@echo "  test              - Run all tests"
	@echo "  test-unit         - Run unit tests"
	@echo "  test-at           - Run acceptance tests"
	@echo "  lint              - Run linting (ruff + mypy + isort check)"
	@echo "  lint-fix          - Run linting with auto-fix"
	@echo "  format            - Format code with ruff"
	@echo "  sort              - Sort imports with isort"
	@echo "  format-all        - Format code and sort imports"
	@echo "  pre-commit-install - Install pre-commit hooks"
	@echo "  pre-commit-run     - Run pre-commit on all files"
	@echo "  pre-commit-update  - Update pre-commit hook versions"

# Development
build-dev:
	docker build --target development -t python-ms-template:dev .

run-dev:
	docker run --rm -it -p 8000:8000 -v $(PWD):/app python-ms-template:dev

# Testing
build-test:
	docker build --target testing -t python-ms-template:test .

run-test:
	docker run --rm -it python-ms-template:test

# Production
build-prod:
	docker build --target production -t python-ms-template:prod .

run-prod:
	docker run --rm -d -p 8000:8000 --name python-ms-template-prod python-ms-template:prod

# Clean up
clean:
	docker rmi python-ms-template:dev python-ms-template:test python-ms-template:prod 2>/dev/null || true
	docker system prune -f

# Build all targets
build-all: build-dev build-test build-prod

# Standard commands
start:
	docker run --rm -d -p 8000:8000 --name python-ms-template-prod python-ms-template:prod

stop:
	docker stop python-ms-template-prod 2>/dev/null || true

add-module:
	@read -p "Enter module name: " module; \
	uv add $$module

remove-module:
	@read -p "Enter module name: " module; \
	uv remove $$module

dependencies:
	uv sync

test:
	uv run pytest -v

test-unit:
	uv run pytest tests/unit/ -v

test-at:
	uv run pytest tests/acceptance/ -v

lint:
	uv run ruff check .
	uv run mypy .
	uv run isort --check-only --diff .

format:
	uv run ruff format .

sort:
	uv run isort .

format-all: format sort

lint-fix:
	uv run ruff check --fix .
	uv run isort .

pre-commit-install:
	uv run pre-commit install

pre-commit-run:
	uv run pre-commit run --all-files

pre-commit-update:
	uv run pre-commit autoupdate

logs:
	docker logs -f python-ms-template-prod

exec:
	docker exec -it python-ms-template-prod /bin/sh
