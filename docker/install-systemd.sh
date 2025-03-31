#!/bin/bash

SERVICE_NAME=n8n-compose
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}.service
WORKDIR=/opt/n8n/docker

echo "🔧 Creating systemd service at $SERVICE_PATH"

sudo tee $SERVICE_PATH > /dev/null <<EOF
[Unit]
Description=n8n Docker Compose App
Requires=docker.service
After=docker.service network.target

[Service]
Type=oneshot
WorkingDirectory=$WORKDIR
ExecStart=/usr/bin/docker-compose --env-file .env up -d
ExecStop=/usr/bin/docker-compose down
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and enabling service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}.service

echo "✅ Done! You can now use:"
echo "  sudo systemctl start $SERVICE_NAME"
echo "  sudo systemctl status $SERVICE_NAME"
