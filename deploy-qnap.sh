#!/bin/bash

# =================================
# FVW KONTAKTVERWALTUNG - QNAP DEPLOYMENT
# =================================

echo "================================================"
echo "  FVW Kontaktverwaltung - QNAP Setup"
echo "================================================"
echo ""

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# =================================
# 1. Prüfe Docker
# =================================
echo -e "${YELLOW}🔍 Prüfe Docker...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker nicht gefunden!${NC}"
    echo "Installiere Container Station über QNAP App Center"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose nicht gefunden!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker läuft${NC}"

# =================================
# 2. Auto-Konfiguration
# =================================
echo ""
echo -e "${YELLOW}⚙️  Erstelle Environment...${NC}"

# Generiere Passwörter
POSTGRES_PW=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
JWT_SECRET=$(openssl rand -base64 32)

# Hole QNAP IP
QNAP_IP=$(hostname -I | awk '{print $1}')
if [ -z "$QNAP_IP" ]; then
    QNAP_IP="localhost"
fi

# Erstelle .env
cat > .env << EOF
# AUTO-GENERIERT - QNAP Deployment

# Database
POSTGRES_PASSWORD=$POSTGRES_PW
POSTGRES_DB=kontakte
POSTGRES_USER=postgres

# JWT
JWT_SECRET=$JWT_SECRET

# API Keys
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# Network
HOST_IP=$QNAP_IP
PUBLIC_PORT=80

# SMTP (optional)
SMTP_ADMIN_EMAIL=admin@example.com
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_SENDER_NAME=FVW Kontaktverwaltung

# Frontend
NEXT_PUBLIC_SUPABASE_URL=http://$QNAP_IP/api
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

NODE_ENV=production
EOF

echo -e "${GREEN}✅ .env erstellt${NC}"
echo -e "   QNAP IP: ${CYAN}$QNAP_IP${NC}"

# =================================
# 3. Verzeichnisse
# =================================
echo ""
echo -e "${YELLOW}📁 Erstelle Verzeichnisse...${NC}"

mkdir -p volumes/postgres
mkdir -p volumes/storage

echo -e "${GREEN}✅ Verzeichnisse OK${NC}"

# =================================
# 4. Starte Services
# =================================
echo ""
echo -e "${YELLOW}🚀 Starte Supabase Stack...${NC}"
echo -e "   (Erster Start: ~2 Minuten für Image-Download)${NC}"
echo ""

docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Start fehlgeschlagen!${NC}"
    exit 1
fi

# =================================
# 5. Health Check
# =================================
echo ""
echo -e "${YELLOW}⏳ Warte auf Postgres...${NC}"

for i in {1..30}; do
    if docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Postgres bereit${NC}"
        break
    fi
    echo -n "."
    sleep 1
    
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Timeout${NC}"
        exit 1
    fi
done

sleep 5

# =================================
# 6. Fertig!
# =================================
echo ""
echo "================================================"
echo -e "${GREEN}  ✅ Deployment erfolgreich!${NC}"
echo "================================================"
echo ""
echo -e "${CYAN}📍 Services erreichbar unter:${NC}"
echo ""
echo -e "   🌐 Web-App:         ${GREEN}http://$QNAP_IP${NC}"
echo -e "   🗄️  Supabase Studio: ${GREEN}http://$QNAP_IP/studio${NC}"
echo -e "   🔌 REST API:        ${GREEN}http://$QNAP_IP/api${NC}"
echo -e "   📊 Traefik:         ${GREEN}http://$QNAP_IP:8080${NC}"
echo ""
echo "================================================"
echo ""
echo -e "${YELLOW}🎯 Nächste Schritte:${NC}"
echo "   1. Öffne Studio: http://$QNAP_IP/studio"
echo "   2. Erstelle User-Account (Authentication > Users)"
echo "   3. Importiere Kontakte oder erstelle manuell"
echo ""
echo -e "${YELLOW}🛑 Stoppen:${NC}    docker compose down"
echo -e "${YELLOW}🔄 Logs:${NC}       docker compose logs -f"
echo ""
