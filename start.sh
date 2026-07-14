#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$ROOT_DIR/.logs"
pids=()
failed=()

warn() { printf "\033[33m%s\033[0m\n" "$*" >&2; }
info() { printf "\033[36m%s\033[0m\n" "$*"; }
ok()   { printf "\033[32m%s\033[0m\n" "$*"; }
err()  { printf "\033[31m%s\033[0m\n" "$*" >&2; }

cleanup() {
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  rm -rf "$LOG_DIR"
}
trap cleanup EXIT

# ------------------------------------------------------------------
info "FullStackListApp — Starting all services"
echo ""

# ---- Check if setup is complete ----------------------------------
check_setup_done() {
  [ -f "$ROOT_DIR/my-api/.venv/bin/fastapi" ]       || return 1
  [ -d "$ROOT_DIR/my-bff/node_modules/express" ]     || return 1
  [ -d "$ROOT_DIR/my-frontend/node_modules/react" ]  || return 1
  return 0
}

if ! check_setup_done; then
  warn "Dependencies not fully installed — running setup.sh"
  echo ""
  bash "$ROOT_DIR/setup.sh"
  echo ""
  if ! check_setup_done; then
    err "Setup incomplete — aborting"
    exit 1
  fi
  ok "Setup complete, proceeding to start"
  echo ""
fi

# ---- Pre-flight port check ---------------------------------------
PORTS=(8000 3001 5173)
taken=()

for port in "${PORTS[@]}"; do
  if command -v curl &>/dev/null; then
    curl -s --connect-timeout 1 "http://localhost:$port" >/dev/null 2>&1 && taken+=("$port")
  elif (echo > "/dev/tcp/localhost/$port") 2>/dev/null; then
    taken+=("$port")
  fi
done

if [ ${#taken[@]} -gt 0 ]; then
  err "Port(s) ${taken[*]} already in use — aborting"
  err "Free the port(s) above and re-run start.sh"
  exit 1
fi
ok "All ports are free"
echo ""

# ---- Start services ----------------------------------------------
rm -rf "$LOG_DIR"
mkdir -p "$LOG_DIR"

start_service() {
  local name="$1"
  local workdir="$2"
  local logfile="$3"
  local port="$4"
  local check_url="$5"
  shift 5
  local cmd=("$@")

  (cd "$workdir" && exec "${cmd[@]}") > "$logfile" 2>&1 &
  local pid=$!
  pids+=("$pid")

  info "Waiting for $name on :$port..."

  for i in $(seq 1 30); do
    if curl -s -o /dev/null --connect-timeout 1 "$check_url" 2>/dev/null; then
      ok "$name ready on http://localhost:$port"
      return 0
    fi
    sleep 1
  done

  err "$name failed to start — check $logfile"
  failed+=("$name")
  return 1
}

start_service "API" "$ROOT_DIR/my-api" \
  "$LOG_DIR/api.log" 8000 "http://localhost:8000/items" \
  "$ROOT_DIR/my-api/.venv/bin/fastapi" dev main.py

start_service "BFF" "$ROOT_DIR/my-bff" \
  "$LOG_DIR/bff.log" 3001 "http://localhost:3001/api/items" \
  node index.js

start_service "Frontend" "$ROOT_DIR/my-frontend" \
  "$LOG_DIR/frontend.log" 5173 "http://localhost:5173" \
  pnpm dev

echo ""
ok "All services started"
echo ""

# ---- TUI menu ----------------------------------------------------
while true; do
  echo "====================================="
  echo "  FullStackListApp — Running"
  echo "====================================="
  echo "  1) View API logs       :8000"
  echo "  2) View BFF logs       :3001"
  echo "  3) View Frontend logs  :5173"
  echo "  q) Quit all services"
  echo "====================================="
  echo ""

  read -r -n 1 key </dev/tty 2>/dev/null || read -r -n 1 key
  echo

  case "$key" in
    1) tail -f "$LOG_DIR/api.log" 2>/dev/null || true ;;
    2) tail -f "$LOG_DIR/bff.log" 2>/dev/null || true ;;
    3) tail -f "$LOG_DIR/frontend.log" 2>/dev/null || true ;;
    q|Q) exit 0 ;;
  esac
done
