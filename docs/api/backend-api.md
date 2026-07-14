# Backend API Reference

Base URL: `http://localhost:8000`

The API is a FastAPI server with an in-memory data store. Data persists only while the server is running.

Interactive Swagger docs are available at `http://localhost:8000/docs`.

---

## `GET /items`

Fetch all items, optionally filtered.

### Query Parameters

| Param | Type | Description |
|---|---|---|
| `name` | string | Filter by name (case-insensitive substring match) |
| `priority` | string | Filter by priority (`Low`, `Medium`, `High`) |
| `method` | string | Filter by method (`1`, `2`) |

### Example

```
GET /items?priority=High&method=1
```

### Response

```json
[
  {
    "id": 1,
    "name": "Item 2",
    "priority": "High",
    "method": "1"
  },
  {
    "id": 4,
    "name": "Item 5",
    "priority": "High",
    "method": "1"
  }
]
```

---

## `POST /items`

Add a new item.

### Request Body

The `id` field is optional — the API auto-generates it from the current list length.

```json
{
  "name": "My Item",
  "priority": "Low",
  "method": "2"
}
```

### Response

Returns the created item with an auto-generated `id`:

```json
{
  "id": 5,
  "name": "My Item",
  "priority": "Low",
  "method": "2"
}
```

---

## `DELETE /items`

Remove an item by ID.

### Request Body

```json
{
  "id": 100
}
```

### Response

```json
{
  "ok": true
}
```

---

## `POST /reset`

Reset the item list to the default 18 items.

### Response

```json
{
  "ok": true
}
```

---

## Data Model (Pydantic Schemas)

### `NewItem` (request body for POST)

| Field | Type | Default |
|---|---|---|
| `id` | `string \| None` | `None` (auto-generated) |
| `name` | string | _(required)_ |
| `priority` | string | `"low"` |
| `method` | string | `"test"` |

### Internal Item (response)

| Field | Type |
|---|---|
| `id` | integer |
| `name` | string |
| `priority` | string |
| `method` | string |
