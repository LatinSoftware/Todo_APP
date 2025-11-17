#!/bin/bash
set -euo pipefail

# ============================
# CONFIG
# ============================
APP_DIR="/home/ssm-user/Todo_APP"
REPO_URL="https://github.com/jmsalcedo/Todo_APP.git"
SERVICE_NAME="todoapp"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
RUN_USER="ec2-user"
PY_BIN="/usr/bin/python3"

# Database info
DB_USER="postgres"
DB_PASS="postgres"
DB_NAME="todos"
DB_HOST_WRITE="todo-task-database.cluster-cwviqcw0mghy.us-east-1.rds.amazonaws.com"
DB_HOST_READ="todo-task-database.cluster-ro-cwviqcw0mghy.us-east-1.rds.amazonaws.com"

echo "==== Updating system ===="
sudo yum update -y

echo "==== Installing packages ===="
sudo yum install -y git python3 python3-pip gcc openssl-devel bzip2-devel libffi-devel

# ============================
# CLONE REPO
# ============================
echo "==== Cloning repo ===="

if [ -d "$APP_DIR" ]; then
    sudo rm -rf "$APP_DIR"
fi

git clone "$REPO_URL" "$APP_DIR"

# ============================
# PERMISSIONS FIX
# ============================

echo "==== Fixing permissions so ec2-user can run the service ===="

sudo chmod 755 /home/ssm-user
sudo chown -R $RUN_USER:$RUN_USER "$APP_DIR"

cd "$APP_DIR"

# ============================
# CREATE .env FILE
# ============================

echo "==== Creating .env file ===="

sudo -u "$RUN_USER" bash -c "cat > $APP_DIR/.env" <<EOF
DATABASE_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST_WRITE}:5432/${DB_NAME}
DATABASE_READ_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST_READ}:5432/${DB_NAME}
DATABASE_WRITE_URL=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST_WRITE}:5432/${DB_NAME}
EOF

sudo chmod 600 $APP_DIR/.env
sudo chown $RUN_USER:$RUN_USER $APP_DIR/.env

echo "==== .env created ===="

# ============================
# CREATE VENV
# ============================

echo "==== Creating virtual environment ===="

set +e
sudo -u "$RUN_USER" $PY_BIN -m venv venv 2> /tmp/venv_err.log
VENV_EXIT=$?
set -e

if [ $VENV_EXIT -ne 0 ]; then
    echo "Native venv failed, installing virtualenv…"
    sudo -u "$RUN_USER" $PY_BIN -m pip install --user virtualenv
    export PATH="/home/${RUN_USER}/.local/bin:${PATH}"
    sudo -u "$RUN_USER" virtualenv -p "$PY_BIN" venv
fi

# ============================
# INSTALL REQUIREMENTS
# ============================

echo "==== Installing requirements ===="

sudo -u "$RUN_USER" bash -c "source $APP_DIR/venv/bin/activate && \
    python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt"

# ============================
# SYSTEMD SERVICE
# ============================

echo "==== Creating systemd service ===="

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Todo FastAPI App
After=network.target

[Service]
User=${RUN_USER}
Group=${RUN_USER}
WorkingDirectory=${APP_DIR}
EnvironmentFile=${APP_DIR}/.env
ExecStart=${APP_DIR}/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5
Environment=PATH=${APP_DIR}/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

[Install]
WantedBy=multi-user.target
EOF

echo "==== Reloading daemon and starting service ===="
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

echo "==== Status ===="
sudo systemctl status "$SERVICE_NAME" --no-pager

echo ""
echo "=========================================="
echo "     SETUP FINISHED"
echo "     FastAPI running on port 8000"
echo "=========================================="
