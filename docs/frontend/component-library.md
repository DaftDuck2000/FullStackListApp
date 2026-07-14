# Component Library

The entire UI is rendered by a single `App` component. Below is a breakdown of each visual section.

---

## Header

```tsx
<h1>Items</h1>
```

Simple page title. Style driven by `App.css`.

---

## Add/Edit Form (`<form className="item-form">`)

| Element | ID (if any) | State | Behavior |
|---|---|---|---|
| Text input | `NameInput` | `name` | Item name (required; submit is blocked if empty) |
| Text input | `PriorityInput` | `priority` | Item priority |
| Text input | `MethodInput` | `method` | Item method |
| Button (submit) | — | — | Calls `addItem()`, then clears form |
| Button (reset) | — | — | Calls `resetList()` — restores defaults |

When editing, the `name`, `priority`, and `method` inputs are populated with the selected item's data. The "Add" button submits the modified data as a new item.

### States

- **Default:** All fields empty, "Add" button ready
- **Editing:** Fields populated with item data, user can modify then click "Add"
- **Error (implicit):** No validation feedback — empty name is silently rejected

---

## Filter Bar (`<div className="filter-bar">`)

| Element | State | Options | Behavior |
|---|---|---|---|
| Text input | `filterName` | — | Case-insensitive substring search; triggers `loadItems()` on every keystroke |
| Dropdown | `filterPriority` | `All priorities` / `Low` / `Medium` / `High` | Triggers `loadItems()` on change |
| Dropdown | `filterMethod` | `All methods` / `1` / `2` | Triggers `loadItems()` on change |

All three filters are combined and sent as query parameters to the API. Changing any filter replaces the full items list.

---

## Item List (`<ul className="item-list">`)

Rendered from `items.map()` — one `<li className="item-card">` per item.

### Empty State

When `items` is an empty array, the list renders as an empty `<ul>`. There is no "no items" message.

### Item Card Layout

```
┌──────────────────────────────────┐
│  Item name                       │
│  Priority: High · Method: 1      │
│                    [Edit] [Remove]│
└──────────────────────────────────┘
```

**Left side:** `.item-info` with:
- Item name (`<div>`)
- Meta line with priority and method, separated by a middle dot (`·`)

**Right side:** `.item-actions` with:
- `Edit` button — calls `editItem(item.id)`
- `Remove` button — calls `removeItem(item.id)`

### States

| State | Visual | Notes |
|---|---|---|
| Loading items | Empty list | No loading spinner or skeleton |
| Error fetching | Empty list | No error message displayed |
| Empty list | Empty `<ul>` | No "no items" message |
| Items present | Rendered cards | Each with Edit/Remove buttons |
| Filter no match | Empty `<ul>` | No "no results" message |

---

## Interaction Summary

| User Action | Effect |
|---|---|
| Type in "New item" field | Updates `name` state |
| Click "Add" | `POST /api/items`, then `GET /api/items` |
| Click "Edit" | Copies item to form (via `removeItem` + state lookup) |
| Click "Remove" | `DELETE /api/items`, then `GET /api/items` |
| Click "Reset" | `POST /api/reset`, then `GET /api/items` |
| Type in search | `GET /api/items?name=...` (every keystroke) |
| Change priority filter | `GET /api/items?priority=...` |
| Change method filter | `GET /api/items?method=...` |
