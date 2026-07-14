# FullStackListApp

Three-tier full-stack application with a FastAPI backend, Express BFF proxy, and React frontend.

## Quick Start

```bash
# One command — installs (if needed) then starts everything
bash start.sh
```

The `start.sh` script:
1. Checks if dependencies are installed; runs `setup.sh` if not
2. Verifies ports 8000, 3001, and 5173 are free
3. Starts all three services in order and waits for each to be ready
4. Shows a menu to view individual service logs or stop everything

Open **http://localhost:5173** in your browser after startup.

### Manual setup

```bash
# Install dependencies only
bash setup.sh

# Start services (3 terminals, in order):
cd my-api   && source .venv/bin/activate && fastapi dev main.py   # :8000
cd my-bff   && pnpm start                                          # :3001
cd my-frontend && pnpm dev                                         # :5173
```

The `setup.sh` script will:
1. Check for prerequisites (Python 3, Node.js, pnpm)
2. Create a Python virtual environment in `my-api/.venv`
3. Ask permission to install Python and Node.js dependencies
4. Install everything inside the project tree — your system stays clean

See [docs/](docs/) for full documentation.
