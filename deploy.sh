#!/usr/bin/env bash
set -euo pipefail

# deploy.sh
# Usage: ./deploy.sh [user]
# - Creates/updates virtualenv, installs requirements
# - Generates a systemd unit for this checkout and enables+starts it
# - Must be run from the repository root

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET_USER="${1:-$(id -un)}"
VENV_DIR="$REPO_ROOT/.venv"
SERVICE_NAME="vm_manager.service"
UNIT_PATH="/etc/systemd/system/$SERVICE_NAME"

echo "Repo root: $REPO_ROOT"
echo "Service user: $TARGET_USER"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. Install Python 3 before running this script." >&2
  exit 1
fi

echo "==> Creating virtualenv (if missing)"
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

echo "==> Activating virtualenv and installing dependencies"
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$REPO_ROOT/backend/requirements.txt"
pip install gunicorn
deactivate

echo "==> Generating systemd unit file"
GENERATED_UNIT="$REPO_ROOT/backend/${SERVICE_NAME}.generated"

cat > "$GENERATED_UNIT" <<EOF
[Unit]
Description=VM_Manager Flask application (VM Manager)
After=network.target

[Service]
Type=simple
User=$TARGET_USER
Group=$TARGET_USER
WorkingDirectory=$REPO_ROOT/backend
Environment=FLASK_ENV=production
ExecStart=/bin/bash -lc 'if [ -f "$VENV_DIR/bin/activate" ]; then . "$VENV_DIR/bin/activate"; fi; cd "$REPO_ROOT/backend" && exec "$VENV_DIR/bin/gunicorn" --workers 3 --bind 0.0.0.0:5000 main:app'
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "Generated unit at: $GENERATED_UNIT"

echo "==> Copying unit to /etc/systemd/system/ (requires sudo)"
sudo cp "$GENERATED_UNIT" "$UNIT_PATH"
sudo chown root:root "$UNIT_PATH"
sudo chmod 644 "$UNIT_PATH"

echo "==> Reloading systemd and enabling service"
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE_NAME"

echo "==> Status (short)"
sudo systemctl status "$SERVICE_NAME" --no-pager

echo "Deployment finished. Use 'sudo journalctl -u $SERVICE_NAME -f' to follow logs."
