#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

warn() { printf "\033[33m%s\033[0m\n" "$*" >&2; }
info() { printf "\033[36m%s\033[0m\n" "$*"; }
ok()   { printf "\033[32m✓ %s\033[0m\n" "$*"; }
err()  { printf "\033[31m%s\033[0m\n" "$*" >&2; }

prompt_yn() {
  local prompt="$1"
  local reply
  read -r -p "$prompt [Y/n] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

install_node() {
  info "Installing Node.js via nvm..."

  if [ -n "${NVM_DIR-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
  fi

  if ! command -v nvm &>/dev/null; then
    local nvm_install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh"
    if command -v curl &>/dev/null; then
      curl -fsSL "$nvm_install_url" | bash || { err "nvm installation failed"; return 1; }
    elif command -v wget &>/dev/null; then
      wget -qO- "$nvm_install_url" | bash || { err "nvm installation failed"; return 1; }
    else
      err "Neither curl nor wget available — can't install nvm."
      err "Install Node.js >= 22 manually, then re-run this script."
      return 1
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  fi

  if ! command -v nvm &>/dev/null; then
    err "nvm not available after install — install Node.js >= 22 manually"
    return 1
  fi

  nvm install 22 || { err "Node.js installation via nvm failed"; return 1; }
  nvm alias default 22
  ok "Node.js $(node --version) installed via nvm"
}

check_prereqs() {
  local missing=0

  if ! command -v python3 &>/dev/null; then
    err "python3 not found — install Python >= 3.14 with the venv module"
    missing=1
  else
    python3 -c "import venv" 2>/dev/null || {
      err "python3 venv module not available"
      missing=1
    }
  fi

  if ! command -v node &>/dev/null; then
    warn "node not found — Node.js >= 22 required"
    if prompt_yn "Install Node.js >= 22 via nvm?"; then
      install_node || missing=1
    else
      missing=1
    fi
  fi

  if ! command -v pnpm &>/dev/null; then
    warn "pnpm not found"
    if command -v npm &>/dev/null; then
      if prompt_yn "Install pnpm globally via 'npm i -g pnpm'?"; then
        npm i -g pnpm
        ok "pnpm installed"
      else
        err "pnpm is required — install it manually: npm i -g pnpm"
        missing=1
      fi
    else
      err "pnpm is required — install Node.js first, then: npm i -g pnpm"
      missing=1
    fi
  fi

  return "$missing"
}

# ------------------------------------------------------------------
info "FullStackListApp — Setup"
echo ""

# ---- Prerequisites -------------------------------------------------
info "Checking prerequisites..."
check_prereqs || {
  err "Prerequisites not satisfied. Aborting."
  exit 1
}
ok "All prerequisites met"
echo ""

# ---- 1. Python API ------------------------------------------------
info "Step 1/3 — Python API (my-api/)"

cd "$ROOT_DIR/my-api"

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
  ok "Virtual environment created at my-api/.venv"
else
  ok "Virtual environment already exists"
fi

source .venv/bin/activate

if [ -f "requirements.txt" ]; then
  if prompt_yn "Install Python packages from requirements.txt?"; then
    pip install -r requirements.txt
    ok "Python packages installed"
  else
    warn "Skipping Python package installation"
  fi
else
  warn "No requirements.txt found — skipping"
fi

deactivate 2>/dev/null || true
echo ""

# ---- 2. BFF -------------------------------------------------------
info "Step 2/3 — BFF Proxy (my-bff/)"

cd "$ROOT_DIR/my-bff"

if prompt_yn "Install Node.js dependencies for the BFF (my-bff/)?"; then
  rm -f pnpm-lock.yaml
  pnpm install
  ok "BFF dependencies installed"
else
  warn "Skipping BFF dependency installation"
fi
echo ""

# ---- 3. Frontend --------------------------------------------------
info "Step 3/3 — Frontend (my-frontend/)"

cd "$ROOT_DIR/my-frontend"

if prompt_yn "Install Node.js dependencies for the Frontend (my-frontend/)?"; then
  rm -f pnpm-lock.yaml
  pnpm install
  ok "Frontend dependencies installed"
else
  warn "Skipping Frontend dependency installation"
fi
echo ""

# ---- Done ---------------------------------------------------------
cat <<EOF
$(ok "Setup complete!")

Start the services in order:

  Terminal 1 — API:
    cd my-api && source .venv/bin/activate && fastapi dev main.py

  Terminal 2 — BFF:
    cd my-bff && pnpm start

  Terminal 3 — Frontend:
    cd my-frontend && pnpm dev

Then open http://localhost:5173
EOF
