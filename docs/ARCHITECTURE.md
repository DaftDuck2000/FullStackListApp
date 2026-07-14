# Architecture

## System Overview

```
┌──────────────┐     /api/*     ┌──────────────┐     HTTP     ┌──────────────┐
│   Browser    │ ─────────────> │ BFF (Express)│ ──────────>  │ API (FastAPI)│
│  React SPA   │ <───────────── │   :3001      │ <──────────  │   :8000      │
│   :5173      │                └──────────────┘              └──────────────┘
└──────────────┘                                                     │
      │                                                              │
      └── Vite dev server proxies /api to :3001                      │
                                                                     │
                                                              ┌──────┴──────┐
                                                              │  In-memory  │
                                                              │  list[dict] │
                                                              └─────────────┘
```

The frontend never talks directly to the backend API. All requests go through the **BFF (Backend-For-Frontend)** layer, which forwards them to the FastAPI server.

During development, Vite's built-in proxy forwards `/api/*` requests from `:5173` to `:3001`.

## Data Model

```typescript
interface Item {
  id: number;
  name: string;
  priority: "Low" | "Medium" | "High";
  method: "1" | "2";
}
```

Data is stored **in-memory** in the Python backend as `list[dict]`. The list is seeded with 18 default items (3 names x 3 priorities x 2 methods).

## Data Flow by Operation

### Create Item
```
[Form Submit] -> POST /api/items {name, priority, method}
  -> BFF forwards POST /items
    -> API auto-generates id and appends to items list
  -> BFF returns created item with id
-> Frontend re-fetches GET /api/items
```

### Read Items (with filters)
```
[Page Load / Filter Change] -> GET /api/items?name=&priority=&method=
  -> BFF forwards GET /items?...
    -> API filters in-memory list
  -> BFF returns filtered items
-> Frontend updates state via setItems()
```

### Update Item (Edit)
```
[Edit Click] -> DELETE /api/items {id}
  -> BFF forwards DELETE /items
    -> API removes item from list
-> Frontend awaits deletion, then copies item data into form
-> User modifies fields and submits -> POST /api/items
```

### Delete Item
```
[Remove Click] -> DELETE /api/items {id}
  -> BFF forwards DELETE /items
    -> API removes item by id
-> Frontend re-fetches GET /api/items
```

### Reset List
```
[Reset Click] -> POST /api/reset
  -> BFF forwards POST /reset
    -> API clears list and re-adds defaults
-> Frontend re-fetches GET /api/items
```

## Tech Stack Details

### Frontend (`my-frontend/`)
- **React 19.2** with JSX transform
- **TypeScript 6.0**
- **Vite 8.1** dev server and bundler
- **Oxlint 1.71** for linting
- Single component (`App.tsx`) with `useState` and `useEffect`

### BFF (`my-bff/`)
- **Express 5.2** with ES modules (`"type": "module"`)
- Thin passthrough proxy — no business logic
- All routes prefixed with `/api`

### Backend API (`my-api/`)
- **Python 3.14** with **FastAPI**
- **Pydantic** for request validation (`NewItem` model)
- No database — in-memory Python list
- Uvicorn (via `fastapi dev`) for serving
