.PHONY: all build up down clean logs ps help

COMPOSE_FILE = srcs/docker-compose.yml

all: build up
	@echo "✅ Project started successfully!"

build:
	@echo "🔨 Building Docker images..."
	docker compose -f $(COMPOSE_FILE) build

up:
	@echo "🚀 Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d

down:
	@echo "🛑 Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down

clean: down
	@echo "🧹 Cleaning up volumes and images..."
	docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -f

logs:
	@echo "📋 Showing logs..."
	docker compose -f $(COMPOSE_FILE) logs -f

ps:
	@echo "📊 Running containers..."
	docker compose -f $(COMPOSE_FILE) ps

restart: down up
	@echo "🔄 Project restarted!"

help:
	@echo "Available commands:"
	@echo "  make all      - Build and start everything (default)"
	@echo "  make build    - Build Docker images"
	@echo "  make up       - Start containers"
	@echo "  make down     - Stop containers"
	@echo "  make clean    - Stop and remove everything (including volumes)"
	@echo "  make logs     - View container logs"
	@echo "  make ps       - Show running containers"
	@echo "  make restart  - Restart the project"
