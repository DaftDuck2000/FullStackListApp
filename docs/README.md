# firstFullStackApp Documentation

A three-tier full-stack demo application built with **React 19**, **Express 5 (BFF)**, and **FastAPI**.

## Architecture

![Architecture: Browser -> BFF -> API](ARCHITECTURE.md)

| Layer | Technology | Port |
|---|---|---|
| Frontend (SPA) | React 19 + TypeScript + Vite | `:5173` |
| BFF (Proxy) | Node.js + Express 5 | `:3001` |
| Backend API | Python 3.14 + FastAPI | `:8000` |

## Quick Start

```bash
# Terminal 1 - API
cd my-api && source .venv/bin/activate && fastapi dev main.py

# Terminal 2 - BFF
cd my-bff && pnpm start

# Terminal 3 - Frontend
cd my-frontend && pnpm dev
```

Then open **http://localhost:5173**.

## Documentation Index

| Document | Description |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design, data model, data flow diagrams |
| [SETUP.md](SETUP.md) | Prerequisites, installation, and running instructions |
| [api/backend-api.md](api/backend-api.md) | FastAPI endpoint reference |
| [api/bff-api.md](api/bff-api.md) | BFF proxy endpoint reference |
| [frontend/overview.md](frontend/overview.md) | Frontend component structure and state flow |
| [frontend/component-library.md](frontend/component-library.md) | UI component breakdown |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Dev workflow, scripts, linting, known issues |

## Project Layout

```
firstFullStackApp/
├── docs/               # Documentation
├── my-api/             # Python FastAPI backend
│   └── main.py         # Single-file API server
├── my-bff/             # Node.js Express BFF
│   └── index.js        # Single-file proxy server
└── my-frontend/        # React + TypeScript frontend
    └── src/
        ├── App.tsx     # Main application component
        ├── App.css     # Application styles
        ├── index.css   # Global styles and CSS variables
        └── main.tsx    # React entry point
```
