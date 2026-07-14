# Development

## Available Scripts

### Frontend (`my-frontend/`)

| Script | Command | Description |
|---|---|---|
| `dev` | `pnpm dev` | Start Vite dev server with hot reload at `:5173` |
| `build` | `pnpm build` | Type-check with `tsc -b`, then bundle with Vite |
| `preview` | `pnpm preview` | Locally preview the production build |
| `lint` | `pnpm lint` | Run Oxlint linting (config: `.oxlintrc.json`) |

### BFF (`my-bff/`)

| Script | Command | Description |
|---|---|---|
| `start` | `pnpm start` | Start Express server on `:3001` |
| `test` | `pnpm test` | Stub — no tests configured |

### API (`my-api/`)

```bash
# Start with hot reload
fastapi dev main.py

# Start in production
fastapi run main.py
```

---

## Code Conventions

- **Frontend:** TypeScript with strict types. Single-component architecture for now.
- **BFF:** ES modules (`"type": "module"` in package.json). Express 5 with `async` route handlers.
- **API:** Python with FastAPI decorators. Pydantic models for request validation.

---

## Known Issues

### 1. No error handling on fetch calls

All `fetch()` calls in the frontend lack `.catch()` or try/catch blocks. Network errors or API failures will fail silently — the UI won't show error states.

---

## Testing

There are currently **no tests** in the project. No test frameworks are configured (no Jest, Vitest, or pytest).

---

## Building for Production

```bash
# 1. Build the frontend
cd my-frontend && pnpm build

# 2. Output goes to my-frontend/dist/
# Serve dist/ with any static file server
```

In production, you would need to serve the built frontend files (via the BFF or a separate web server) instead of relying on Vite's dev proxy. The current setup is development-only.
