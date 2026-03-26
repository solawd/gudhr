#!/bin/bash

# Configuration
SERVICE_NAME="gudhr"
PROJECT_DIR=$(pwd)
USER=$(whoami)

# Based on the README.md instructions, the virtual environment is named horillavenv
# We will use that, but fall back to .venv if horillavenv doesn't exist.
if [ -d "$PROJECT_DIR/gudhr_venv" ]; then
    VENV_DIR="$PROJECT_DIR/gudhr_venv"
elif [ -d "$PROJECT_DIR/.venv" ]; then
    VENV_DIR="$PROJECT_DIR/.venv"
else
    echo "Error: Virtual environment not found. Please set it up as per README.md"
    exit 1
fi

PYTHON_BIN="$VENV_DIR/bin/python"

echo "Configuring the $SERVICE_NAME service..."

# Create the systemd service file
cat <<EOF | sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null
[Unit]
Description=GudHR HRMS Django Application
After=network.target

[Service]
User=$USER
# The group might need to be adjusted depending on the OS (e.g. www-data on Ubuntu, staff on macOS/some Linux)
WorkingDirectory=$PROJECT_DIR
ExecStart=$PYTHON_BIN manage.py runserver 0.0.0.0:8000
Restart=always
RestartSec=3
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$SERVICE_NAME

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling $SERVICE_NAME service to start on boot..."
sudo systemctl enable ${SERVICE_NAME}

echo "Starting $SERVICE_NAME service..."
sudo systemctl start ${SERVICE_NAME}

echo "================================================="
echo "Horilla service installed and started successfully!"
echo "You can access the system at http://localhost:8000"
echo "Check the service status using: sudo systemctl status ${SERVICE_NAME}"
echo "View the logs using: sudo journalctl -u ${SERVICE_NAME} -f"
echo "================================================="
