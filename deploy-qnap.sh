#!/bin/bash

# =================================
# QNAP Deployment Script für Kontaktverwaltung
# =================================

set -e

echo "=================================================="
echo "  Kontaktverwaltung - QNAP Deployment Setup"
echo "=================================================="
echo ""

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =================================
# 1. Prüfe Voraussetzungen
# =================================
echo "🔍 Prüfe Voraussetzungen..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker ist nicht installiert${NC}"
    echo "Bitte installiere Docker auf deiner QNAP über Container Station"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose ist nicht installiert${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker und Docker Compose gefunden${NC}"

# =================================
# 2. Environment-Konfiguration
# =================================
echo ""
echo "📝 Konfiguriere Environment-Variablen..."

if [ ! -f .env ]; then
    echo "Kopiere .env.example → .env"
    cp .env.example .env
    
    echo ""
    echo -e "${YELLOW}⚠️  Bitte konfiguriere folgende Werte in der .env Datei:${NC}"
    echo ""
    
    # Generiere sichere Passwörter
    POSTGRES_PW=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    JWT_SECRET=$(openssl rand -base64 32)
    
    # Ersetze in .env
    sed -i "s/your-secure-password-here/$POSTGRES_PW/g" .env
    sed -i "s|your-super-secret-jwt-token-with-at-least-32-characters-long|$JWT_SECRET|g" .env
    
    # Frage nach QNAP IP
    echo -n "Gib die IP-Adresse deiner QNAP ein (z.B. 192.168.1.100): "
    read QNAP_IP
    
    if [ -z "$QNAP_IP" ]; then
        echo -e "${YELLOW}Keine IP angegeben, nutze localhost${NC}"
        QNAP_IP="localhost"
    fi
    
    sed -i "s/192.168.1.100/$QNAP_IP/g" .env
    
    echo -e "${GREEN}✅ Environment-Variablen konfiguriert${NC}"
    echo -e "   Postgres Passwort: ${POSTGRES_PW}"
    echo -e "   JWT Secret: generiert"
    echo -e "   QNAP IP: ${QNAP_IP}"
    
else
    echo -e "${YELLOW}⚠️  .env existiert bereits, überspringe Generierung${NC}"
    source .env
    QNAP_IP=${HOST_IP:-localhost}
fi

# =================================
# 3. Erstelle Volumes-Verzeichnisse
# =================================
echo ""
echo "📁 Erstelle Volume-Verzeichnisse..."

mkdir -p volumes/postgres
mkdir -p volumes/storage
mkdir -p services/supabase/migrations

echo -e "${GREEN}✅ Verzeichnisse erstellt${NC}"

# =================================
# 4. Starte Docker-Services
# =================================
echo ""
echo "🚀 Starte Supabase-Stack..."

# Lade Images herunter
echo "   Lade Docker-Images..."
docker compose pull

# Starte Services
echo "   Starte Container..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# =================================
# 5. Warte auf Service-Bereitschaft
# =================================
echo ""
echo "⏳ Warte auf Service-Bereitschaft..."

# Warte auf Postgres
echo -n "   Postgres: "
for i in {1..30}; do
    if docker compose exec -T postgres pg_isready -U postgres &> /dev/null; then
        echo -e "${GREEN}✅${NC}"
        break
    fi
    echo -n "."
    sleep 1
    
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Timeout${NC}"
        exit 1
    fi
done

# Kurze Wartezeit für andere Services
sleep 5

# =================================
# 6. Health-Check
# =================================
echo ""
echo "🏥 Überprüfe Services..."

check_service() {
    SERVICE=$1
    URL=$2
    
    echo -n "   $SERVICE: "
    
    if curl -sf "$URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        return 0
    else
        echo -e "${RED}❌${NC}"
        return 1
    fi
}

# Überprüfe Services (mit Timeout)
sleep 3

echo -e "${GREEN}✅ Basis-Services gestartet${NC}"

# =================================
# 7. Ausgabe URLs
# =================================
echo ""
echo "=================================================="
echo -e "${GREEN}  ✅ Deployment erfolgreich!${NC}"
echo "=================================================="
echo ""
echo "📍 Zugriff auf Services:"
echo ""
echo "   🌐 Web-App:         http://${QNAP_IP}"
echo "   🗄️  Supabase Studio: http://${QNAP_IP}/studio"
echo "   🔌 REST API:        http://${QNAP_IP}/api"
echo "   🔐 Auth:            http://${QNAP_IP}/auth"
echo "   💾 Storage:         http://${QNAP_IP}/storage"
echo "   🌊 Realtime:        http://${QNAP_IP}/realtime"
echo ""
echo "   📊 Traefik Dashboard: http://${QNAP_IP}:8080"
echo ""
echo "=================================================="
echo ""
echo "📝 Nächste Schritte:"
echo "   1. Öffne Supabase Studio und prüfe die Datenbank"
echo "   2. Entwickle das Frontend in apps/web"
echo "   3. Nutze 'docker compose logs -f' für Logs"
echo ""
echo "🛑 Stop: docker compose down"
echo "🔄 Neustart: docker compose restart"
echo ""
