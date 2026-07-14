# Setup

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Python | >= 3.14 | With `venv` module |
| Node.js | >= 22 | Tested with latest LTS |
| pnpm | >= 11.11 | Install via `npm i -g pnpm` |

## 1. Backend API (`my-api/`)

```bash
cd my-api

# Activate virtual environment
source .venv/bin/activate

# (If .venv doesn't exist yet)
python -m venv .venv && source .venv/bin/activate

# Install dependencies
pip install fastapi uvicorn

# Start the API server
fastapi dev main.py
```

The API runs on **http://localhost:8000**.

FastAPI provides interactive docs at **http://localhost:8000/docs**.

## 2. BFF Proxy (`my-bff/`)

```bash
cd my-bff

# Install dependencies
pnpm install

# Start the BFF server
pnpm start
```

The BFF runs on **http://localhost:3001**.

## 3. Frontend (`my-frontend/`)

```bash
cd my-frontend

# Install dependencies
pnpm install

# Start the Vite dev server
pnpm dev
```

The frontend runs on **http://localhost:5173**.

## Startup Order

Always start services in this order:

1. **API** (port 8000) — the backend with data
2. **BFF** (port 3001) — proxies requests to the API
3. **Frontend** (port 5173) — makes requests to the BFF via Vite proxy

## Verifying the Setup

| Check | URL | Expected |
|---|---|---|
| API health | `http://localhost:8000/items` | JSON array of items |
| BFF proxy | `http://localhost:3001/api/items` | Same JSON array |
| Frontend | `http://localhost:5173` | The item manager UI |

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| Blank page, no data | API not running | Start the API first |
| Frontend loads but no items | BFF not running | Start the BFF |
| CORS errors in console | Missing CORS headers | BFF should forward; or run API on same proxy |
| `command not found: fastapi` | FastAPI not installed | `pip install fastapi uvicorn` in the venv |
| `pnpm: command not found` | pnpm not installed | `npm i -g pnpm` |
