# 🚀 FVW Kontaktverwaltung – QNAP Production Deployment

> **Enterprise-ready deployment guide** für das FVW Contact Management System mit vollständigem Supabase Stack auf QNAP Container Station.

---

## 📋 Inhaltsverzeichnis

1. [Systemvoraussetzungen](#systemvoraussetzungen)
2. [Installation](#installation)
3. [Konfiguration](#konfiguration)
4. [Service Management](#service-management)
5. [Updates & Wartung](#updates--wartung)
6. [Monitoring & Logs](#monitoring--logs)
7. [Troubleshooting](#troubleshooting)
8. [Sicherheit & Best Practices](#sicherheit--best-practices)

---

## 🔧 Systemvoraussetzungen

### Hardware-Anforderungen

| Komponente | Minimum | Empfohlen |
|------------|---------|-----------|
| RAM | 2 GB | 4 GB |
| CPU | 2 Cores | 4 Cores |
| Storage | 10 GB | 20 GB |

### Software-Voraussetzungen

- ✅ **QNAP QTS** 5.0+ oder QuTS hero h5.0+
- ✅ **Container Station** 3.0+ installiert (verfügbar im QNAP App Center)
  - Container Station stellt Docker & Docker Compose bereit (keine separate Docker-Installation nötig)
  - Bietet sowohl GUI-Verwaltung als auch CLI-Zugriff via SSH
- ✅ **SSH-Zugriff** aktiviert (Systemsteuerung → Netzwerk & Dateidienste → Telnet/SSH)
- ✅ **Git** verfügbar (wird automatisch mit Container Station installiert)

### Netzwerk-Anforderungen

- 🌐 **Port 80** verfügbar (Standard-Webzugriff)
  - Alternativ: Beliebiger Port konfigurierbar (z.B. 8080, 8081)
- 📊 **Port 8080** verfügbar (Traefik Dashboard, optional)
- 🔒 Statische IP-Adresse im lokalen Netzwerk empfohlen

> [!NOTE]
> **Container Station** ist QNAPs Docker-Plattform. Nach Installation über den App Center stehen `docker` und `docker compose` Kommandos via SSH zur Verfügung.

> [!TIP]
> Für produktiven Einsatz empfehlen wir eine **DNS-Reservierung** im Router, damit das QNAP immer unter derselben IP erreichbar ist.

---

## 🚀 Installation

### Option 1: Automatische Installation (Empfohlen)

**Single-Command-Deployment** – Das Setup-Script erledigt alles automatisch:

```bash
# 1. SSH-Verbindung zum QNAP herstellen
ssh admin@192.168.1.100  # IP durch deine QNAP-IP ersetzen

# 2. In Container Station Verzeichnis wechseln
cd /share/Container

# 3. Repository klonen
git clone https://github.com/thomaslutzkolter/fvw.git
cd fvw

# 4. Automatisches Setup ausführen
chmod +x deploy-qnap.sh
./deploy-qnap.sh
```

**Das Script führt folgende Schritte aus:**

1. ✅ Prüft Container Station (Docker & Docker Compose)
2. ✅ Generiert sichere Passwörter und JWT-Secrets
3. ✅ Erstellt `.env`-Datei mit Auto-Konfiguration
4. ✅ Richtet Datenverzeichnisse ein
5. ✅ Startet alle Services (Postgres, PostgREST, GoTrue, Realtime, Storage, Studio)
6. ✅ Wartet auf vollständige Service-Bereitschaft
7. ✅ Zeigt Zugriffs-URLs an

**Erfolgsmeldung:**

```
================================================
  ✅ Deployment erfolgreich!
================================================

📍 Services erreichbar unter:

   🌐 Web-App:         http://192.168.1.100
   🗄️  Supabase Studio: http://192.168.1.100/studio
   🔌 REST API:        http://192.168.1.100/api
   � Traefik:         http://192.168.1.100:8080
```

> [!IMPORTANT]
> Der **erste Start** dauert ca. 2-3 Minuten, da Docker Images heruntergeladen werden müssen (~1.5 GB).

---

### Option 2: Manuelle Installation

Für fortgeschrittene Nutzer mit spezifischen Konfigurationsbedürfnissen:

```bash
# 1. Repository klonen
cd /share/Container
git clone https://github.com/thomaslutzkolter/fvw.git
cd fvw

# 2. Environment-Datei erstellen
cp .env.example .env

# 3. Konfiguration anpassen (siehe Abschnitt Konfiguration)
nano .env

# 4. Services starten
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 5. Logs überwachen
docker compose logs -f
```

---

## ⚙️ Konfiguration

### Environment-Variablen (`.env`)

Die `.env`-Datei wird beim automatischen Setup generiert. Für manuelle Anpassungen:

#### Kritische Konfiguration

```bash
# Database
POSTGRES_PASSWORD=<auto-generiert-32-zeichen>  # Von deploy-qnap.sh
POSTGRES_DB=kontakte
POSTGRES_USER=postgres

# JWT Secret (von deploy-qnap.sh generiert)
JWT_SECRET=<auto-generiert-base64>

# Netzwerk
HOST_IP=192.168.1.100      # Automatisch erkannt
PUBLIC_PORT=80             # Standard-Port
```

#### SMTP-Konfiguration (Optional)

Für E-Mail-Verifikation bei Benutzerregistrierung:

```bash
SMTP_ADMIN_EMAIL=admin@ihre-domain.de
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=ihre-email@gmail.com
SMTP_PASS=ihr-app-passwort
SMTP_SENDER_NAME=FVW Kontaktverwaltung
```

> [!NOTE]
> Ohne SMTP-Konfiguration funktioniert die Anwendung, aber **E-Mail-Verifikation** ist deaktiviert.

#### Port-Anpassung

Port 80 bereits belegt? Kein Problem:

```bash
# In .env ändern:
PUBLIC_PORT=8081

# Services neu starten
docker compose down
docker compose up -d
```

Zugriff dann über: `http://192.168.1.100:8081`

---

## 🔄 Service Management

### Basis-Kommandos

```bash
cd /share/Container/fvw

# Alle Services starten
docker compose up -d

# Services stoppen
docker compose down

# Services neustarten
docker compose restart

# Status aller Services
docker compose ps

# Einzelnen Service neustarten
docker compose restart postgres
docker compose restart studio
```

### Service-Übersicht

| Service | Container Name | Funktion | Port (intern) |
|---------|---------------|----------|---------------|
| **traefik** | kontakte-traefik | Reverse Proxy & Routing | 80, 8080 |
| **postgres** | kontakte-postgres | PostgreSQL 15 Datenbank | 5432 |
| **postgrest** | kontakte-postgrest | Auto-generierte REST API | 3000 |
| **gotrue** | kontakte-gotrue | Authentication & JWT | 9999 |
| **realtime** | kontakte-realtime | WebSocket Subscriptions | 4000 |
| **storage** | kontakte-storage | File Upload & Management | 5000 |
| **imgproxy** | kontakte-imgproxy | Image Transformation | 5001 |
| **studio** | kontakte-studio | Supabase Admin UI | 3000 |

### Automatischer Start nach Neustart

Services werden durch `restart: unless-stopped` automatisch nach QNAP-Neustart gestartet.

---

## 🔄 Updates & Wartung

### Updates vom GitHub Repository

```bash
cd /share/Container/fvw

# 1. Änderungen pullen
git pull origin main

# 2. Services neu starten
docker compose down
docker compose up -d

# 3. Erfolg verifizieren
docker compose ps
```

### Docker Image Updates

```bash
# Images aktualisieren
docker compose pull

# Mit neuen Images neu starten
docker compose down
docker compose up -d
```

### Database Migrations

Neue Migrationen werden automatisch beim Start ausgeführt:

```bash
# Migrations liegen in:
ls -la services/supabase/migrations/

# Werden geladen bei Container-Start durch:
volumes:
  - ./services/supabase/migrations:/docker-entrypoint-initdb.d:ro
```

---

## 📊 Monitoring & Logs

### Logs in Echtzeit

```bash
# Alle Services
docker compose logs -f

# Spezifischer Service
docker compose logs -f postgres
docker compose logs -f studio
docker compose logs -f traefik

# Letzte 100 Zeilen
docker compose logs --tail=100

# Zeitstempel anzeigen
docker compose logs -f --timestamps
```

### Resource-Monitoring

```bash
# Container-Statistiken (CPU, RAM, Netzwerk)
docker stats

# Disk Usage
docker system df
```

### Traefik Dashboard

Zugriff auf Routing-Übersicht:

```
http://192.168.1.100:8080
```

Zeigt:
- Aktive Routen
- Backend-Services
- Health Status
- Request-Statistiken

---

## 🛠️ Troubleshooting

### Services starten nicht

**Problem:** `docker compose up -d` schlägt fehl

**Lösung:**

```bash
# 1. Prüfe Docker-Status
docker info

# 2. Prüfe Port-Konflikte
netstat -tuln | grep ':80'

# 3. Prüfe Container-Logs
docker compose logs

# 4. Services komplett neu aufsetzen
docker compose down -v  # ACHTUNG: Löscht Datenbank!
docker compose up -d
```

---

### Postgres startet nicht

**Problem:** `kontakte-postgres` bleibt in `starting` Status

**Lösung:**

```bash
# 1. Logs prüfen
docker compose logs postgres

# 2. Häufige Ursachen:
# - Unzureichender RAM (mindestens 2GB erforderlich)
# - Korrupte Datenbank-Dateien

# 3. Datenbank neu initialisieren (ACHTUNG: Löscht alle Daten!)
docker compose down
docker volume rm fvw_postgres-data
docker compose up -d
```

---

### Service nicht erreichbar über Browser

**Problem:** `http://192.168.1.100/studio` lädt nicht

**Lösung:**

```bash
# 1. Prüfe Service-Status
docker compose ps

# 2. Prüfe Traefik-Routen
curl http://localhost:8080/api/http/routers

# 3. Prüfe Firewall
# QNAP: Systemsteuerung → Sicherheit → Firewall → Port 80 öffnen

# 4. Browser-Cache leeren und neu laden
```

---

### Port 80 bereits belegt

**Problem:** `Error: Port 80 already in use`

**Lösung:**

```bash
# 1. Prüfe welcher Prozess Port 80 nutzt
netstat -tuln | grep ':80'

# 2. Nutze anderen Port
# In .env ändern:
PUBLIC_PORT=8081

# 3. Services neu starten
docker compose down
docker compose up -d

# Zugriff dann über: http://192.168.1.100:8081
```

---

### "Out of Memory" Fehler

**Problem:** Container stürzen ab mit OOM-Fehlern

**Lösung:**

```bash
# 1. Speicher-Limits prüfen
docker stats

# 2. Container Station Einstellungen anpassen
# QNAP Container Station → Einstellungen → Resource Limits erhöhen

# 3. Nicht benötigte Services deaktivieren
# In docker-compose.yml imgproxy auskommentieren falls nicht benötigt
```

---

### Daten-Verlust nach Update

**Problem:** Nach `git pull` sind Kontakte weg

**Ursache:** `docker compose down -v` löscht Volumes!

**Lösung:**

```bash
# NIEMALS mit -v Flag stoppen!
# Falsch:
docker compose down -v  # ❌ Löscht ALLE Daten!

# Richtig:
docker compose down     # ✅ Behält Daten

# Backup-Strategie:
# Erstelle regelmäßig Datenbank-Dumps
docker compose exec postgres pg_dump -U postgres kontakte > backup.sql
```

---

## 🔒 Sicherheit & Best Practices

### Produktions-Checkliste

- [ ] **Sichere Passwörter** in `.env` generiert (automatisch durch deploy-qnap.sh)
- [ ] **Firewall** konfiguriert (nur Port 80/443 von außen erreichbar)
- [ ] **SMTP** konfiguriert für E-Mail-Verifikation
- [ ] **Backup-Strategie** implementiert (siehe unten)
- [ ] **HTTPS** eingerichtet (optional, siehe unten)
- [ ] **Zugriffsbeschränkung** auf lokales Netzwerk (QNAP Firewall)

### Backup-Strategie

#### Automatisches Datenbank-Backup

```bash
# Backup-Script erstellen
cat > /share/Container/fvw/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/share/Container/fvw/backups"
mkdir -p $BACKUP_DIR

docker compose exec -T postgres pg_dump -U postgres kontakte > "$BACKUP_DIR/kontakte_$DATE.sql"

# Alte Backups löschen (älter als 30 Tage)
find $BACKUP_DIR -name "kontakte_*.sql" -mtime +30 -delete

echo "Backup erstellt: kontakte_$DATE.sql"
EOF

chmod +x backup.sh

# Cron-Job einrichten (täglich um 2 Uhr nachts)
crontab -e
# Zeile hinzufügen:
0 2 * * * /share/Container/fvw/backup.sh
```

#### Backup wiederherstellen

```bash
# Backup einspielen
docker compose exec -T postgres psql -U postgres kontakte < backups/kontakte_20260211_020000.sql
```

---

### HTTPS mit Let's Encrypt (Optional)

Für externen Zugriff mit SSL-Verschlüsselung:

> [!WARNING]
> Externe Freigabe sollte nur mit **zusätzlichen Sicherheitsmaßnahmen** erfolgen (VPN empfohlen).

```bash
# 1. Domain auf QNAP-IP zeigen lassen (z.B. fvw.ihre-domain.de)

# 2. Port-Forwarding im Router: 443 → QNAP:443

# 3. Traefik mit Let's Encrypt konfigurieren
# In docker-compose.yml erweitern:
command:
  - "--certificatesresolvers.letsencrypt.acme.email=ihre-email@domain.de"
  - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
  - "--entrypoints.websecure.address=:443"

# 4. Services neu starten
docker compose up -d
```

---

### Access Control

**Supabase Studio schützen:**

```bash
# In docker-compose.yml Studio-Labels erweitern:
labels:
  - "traefik.http.routers.studio.middlewares=studio-auth"
  - "traefik.http.middlewares.studio-auth.basicauth.users=admin:$$apr1$$..."

# Passwort generieren:
htpasswd -nb admin IhrPasswort
```

---

## 📈 Performance-Optimierung

### PostgreSQL Tuning

Für größere Datenmengen (>10.000 Kontakte):

```bash
# In docker-compose.yml unter postgres → environment:
POSTGRES_SHARED_BUFFERS: 256MB
POSTGRES_EFFECTIVE_CACHE_SIZE: 1GB
POSTGRES_WORK_MEM: 16MB
```

### Container Resource Limits

```yaml
# In docker-compose.yml für kritische Services:
postgres:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        memory: 1G
```

---

## 📞 Support & Weiterführende Ressourcen

- **GitHub Repository:** [https://github.com/thomaslutzkolter/fvw](https://github.com/thomaslutzkolter/fvw)
- **Supabase Dokumentation:** [https://supabase.com/docs](https://supabase.com/docs)
- **QNAP Container Station:** [QNAP Support](https://www.qnap.com/go/software/container-station)

---

## 📝 Changelog

- **2026-02-11:** Initiale QNAP-Deployment-Dokumentation
- Automatisches Setup-Script mit Auto-Konfiguration
- Production-ready Docker Compose Stack
- Traefik Reverse Proxy Integration

---

**Viel Erfolg mit deinem FVW Contact Management System! 🚀**
