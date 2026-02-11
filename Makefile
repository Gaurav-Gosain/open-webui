
ifneq ($(shell which docker-compose 2>/dev/null),)
    DOCKER_COMPOSE := docker-compose
else
    DOCKER_COMPOSE := docker compose
endif

WEBUI_BASE_PATH ?= /chat
BACKEND_PORT ?= 8080

install:
	$(DOCKER_COMPOSE) up -d

remove:
	@chmod +x confirm_remove.sh
	@./confirm_remove.sh

start:
	$(DOCKER_COMPOSE) start
startAndBuild:
	$(DOCKER_COMPOSE) up -d --build

stop:
	$(DOCKER_COMPOSE) stop

update:
	# Calls the LLM update script
	chmod +x update_ollama_models.sh
	@./update_ollama_models.sh
	@git pull
	$(DOCKER_COMPOSE) down
	# Make sure the ollama-webui container is stopped before rebuilding
	@docker stop open-webui || true
	$(DOCKER_COMPOSE) up --build -d
	$(DOCKER_COMPOSE) start

# ── Dev with custom base path ────────────────────────────────────────
# Usage:
#   make dev                     # frontend + backend at /chat
#   make dev WEBUI_BASE_PATH=/x  # override the base path
#   make dev-frontend            # frontend only
#   make dev-backend             # backend only

.PHONY: dev dev-install dev-frontend dev-backend dev-stop dev-build

dev-install:
	bun install
	uv pip install -r backend/requirements.txt --system 2>/dev/null || \
		uv pip install -r backend/requirements.txt

dev: dev-backend dev-frontend

dev-frontend:
	@echo "Starting frontend at http://localhost:5173$(WEBUI_BASE_PATH)/"
	WEBUI_BASE_PATH=$(WEBUI_BASE_PATH) bun run dev &

dev-backend:
	@echo "Starting backend at http://localhost:8080$(WEBUI_BASE_PATH)/"
	WEBUI_BASE_PATH=$(WEBUI_BASE_PATH) ENABLE_WEBSOCKET_SUPPORT=false \
		.venv/bin/uvicorn open_webui.main:application \
		--host 0.0.0.0 --port 8080 --reload \
		--app-dir backend &

dev-stop:
	@echo "Stopping dev servers..."
	-@pkill -f "vite dev" 2>/dev/null || true
	-@pkill -f "uvicorn open_webui.main:application" 2>/dev/null || true
	@echo "Done."

dev-build:
	@echo "Building frontend with WEBUI_BASE_PATH=$(WEBUI_BASE_PATH)"
	WEBUI_BASE_PATH=$(WEBUI_BASE_PATH) bun run build

