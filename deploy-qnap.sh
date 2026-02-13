#!/bin/bash
set -e

echo "🧹 Cleanup alter Container..."
cd /share/Public/fvw
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml down -v 2>/dev/null || true

echo "📥 Lade neuesten Code..."
rm -rf fvw-main main.zip
wget -q -O main.zip https://github.com/thomaslutzkolter/fvw/archive/refs/heads/main.zip
unzip -q -o main.zip

echo "🔄 Ersetze alte Dateien..."
rm -rf apps packages services docker-compose.yml docker-compose.prod.yml deploy-qnap.sh
cp -r fvw-main/* .
rm -rf fvw-main main.zip

echo "🔧 Generiere .env mit QNAP-IP..."
DETECTED_IP=$(ip route get 1 | awk '{print $7}' | head -1)
cat > .env << EOF
# Database Config
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(openssl rand -base64 32)
POSTGRES_DB=kontakte
POSTGRES_PORT=5432

# Auth Config (Supabase)
JWT_SECRET=$(openssl rand -base64 64)
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# Network Config
HOST_IP=${DETECTED_IP}
PUBLIC_PORT=8081

# SMTP (optional)
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_SENDER_NAME=FVW Kontakte
EOF

echo "🏗️  Baue Frontend Image..."
sudo HOME=/tmp docker build --no-cache -t fvw-web:local apps/web

echo "🚀 Starte Services..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo ""
echo "✅ DEPLOYMENT ERFOLGREICH!"
echo ""
echo "📍 Zugriff unter: http://${DETECTED_IP}:8081/"
echo "📍 Studio unter:  http://${DETECTED_IP}:8081/studio/"
echo "📍 API unter:     http://${DETECTED_IP}:8081/api/"
echo ""
echo "⚠️  Im Browser: Strg+Shift+R für Hard-Reload!"
