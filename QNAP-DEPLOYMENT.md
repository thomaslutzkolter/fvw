# 🚀 FVW Kontaktverwaltung – QNAP Production Deployment

> **Production-ready deployment guide** für das FVW Contact Management System Backend auf QNAP Container Station.

---

## ⚠️ Aktueller Status

**Verfügbare Services:**
- ✅ **Supabase Studio** – Datenbank-Verwaltung & SQL-Editor
- ✅ **REST API** – Auto-generierte API (PostgREST)
- ✅ **Authentication** – User-Management (GoTrue)
- ✅ **Realtime** – WebSocket Subscriptions
- ✅ **Storage** – File Upload & Management

**Noch nicht verfügbar:**
- ⏳ **Web-Frontend** – Aktuell in Entwicklung (auskommentiert in docker-compose.yml)

---

## 📋 Voraussetzungen

| Komponente | Erforderlich |
|------------|--------------|
| QNAP QTS | 5.0+ |
| Container Station | Installiert & gestartet |
| SSH-Zugriff | Aktiviert |
| RAM | Min. 2 GB frei |
| Port 80 | Verfügbar |

> [!IMPORTANT]
> **Git nicht erforderlich!** Diese Anleitung nutzt `wget` für den Download.

---

## 🚀 Installation (5 Minuten)

### Schritt 1: SSH-Verbindung

```bash
ssh dein-user@deine-qnap-ip
```

### Schritt 2: Repository herunterladen

```bash
# Zu Public Share wechseln
cd /share/Public

# Repo als ZIP holen
wget https://github.com/thomaslutzkolter/fvw/archive/refs/heads/main.zip

# Entpacken
unzip main.zip

# Umbenennen
mv fvw-main fvw

# ZIP löschen
rm main.zip

# Ins Verzeichnis wechseln
cd fvw
```

> [!TIP]
> **Alternativer Pfad:** Falls `/share/Public` nicht existiert, nutze `/share/homes/dein-username`

### Schritt 3: Deployment starten

```bash
# Script ausführbar machen
chmod +x deploy-qnap.sh

# Auto-Deployment starten
./deploy-qnap.sh
```

**Das Script macht:**
1. ✅ Prüft Container Station
2. ✅ Generiert sichere Passwörter
3. ✅ Erstellt `.env` automatisch
4. ✅ Startet alle Backend-Services
5. ✅ Wartet auf Postgres-Bereitschaft
6. ✅ Zeigt Zugriffs-URLs

**Erfolgsmeldung:**

```
================================================
  ✅ Deployment erfolgreich!
================================================

📍 Services erreichbar unter:

   🗄️  Supabase Studio: http://192.168.1.100/studio
   🔌 REST API:        http://192.168.1.100/api
```

> [!IMPORTANT]
> **Erster Start:** Download der Docker Images dauert 5-7 Minuten (~1.5 GB).

---

## 🌐 Services nutzen

### Supabase Studio (Datenbank-UI)

```
http://deine-qnap-ip/studio
```

**Features:**
- SQL-Editor
- Table Editor
- Datenbank-Browser
- Query-Builder

**Erstnutzung:**
- Studio startet mit **leerer Datenbank**
- Tabellen müssen manuell erstellt werden (siehe Schema-Dokumentation)
- Oder: Migrationen manuell ausführen (siehe Troubleshooting)

### REST API

```
http://deine-qnap-ip/api
```

**Zugriff testen:**

```bash
# Health-Check
curl http://deine-qnap-ip/api

# API-Schema (nach DB-Setup)
curl http://deine-qnap-ip/api
```

---

## 🔄 Verwaltung

### Services starten/stoppen

```bash
cd /share/Public/fvw

# Status prüfen
docker compose ps

# Stoppen
docker compose down

# Starten
docker compose up -d

# Neu starten
docker compose restart

# Logs anzeigen
docker compose logs -f
```

### Updates vom GitHub

```bash
cd /share/Public

# Altes löschen
rm -rf fvw

# Neu holen
wget https://github.com/thomaslutzkolter/fvw/archive/refs/heads/main.zip
unzip main.zip
mv fvw-main fvw
rm main.zip

# Container neu starten
cd fvw
docker compose down
docker compose up -d
```

---

## 🛠️ Troubleshooting

### Problem: Port 80 bereits belegt

**Symptom:** `bind: address already in use`

**Lösung:**

```bash
nano .env

# PUBLIC_PORT ändern auf z.B. 8081
PUBLIC_PORT=8081

# Neu starten
docker compose down
docker compose up -d
```

Zugriff dann über: `http://deine-qnap-ip:8081/studio`

---

### Problem: Postgres startet nicht

**Symptom:** `dependency failed to start: container kontakte-postgres is unhealthy`

**Lösung 1: Logs prüfen**

```bash
docker compose logs postgres
```

**Lösung 2: Daten-Volume zurücksetzen**

```bash
# ACHTUNG: Löscht alle Daten!
docker compose down
docker volume rm fvw_postgres-data
docker compose up -d
```

---

### Problem: "Permission denied" bei Migrations

**Erklärung:** Das Migrations-Volume wurde entfernt, da es auf QNAP zu Permission-Problemen führt.

**Datenbank-Schema manuell erstellen:**

1. Öffne Supabase Studio: `http://deine-qnap-ip/studio`
2. Gehe zu **SQL Editor**
3. Führe Migrationen manuell aus (Schema-SQL von GitHub holen)

Oder per Kommandozeile:

```bash
# Migrations manuell ausführen
docker compose exec -T postgres psql -U postgres -d kontakte < pfad/zu/001_initial_schema.sql
docker compose exec -T postgres psql -U postgres -d kontakte < pfad/zu/002_functions.sql
```

---

### Services komplett neu aufsetzen

```bash
# ACHTUNG: Löscht ALLE Daten!
docker compose down -v
docker compose up -d
```

---

## 📊 Service-Übersicht

| Service | Container | Port | Funktion |
|---------|-----------|------|----------|
| Traefik | kontakte-traefik | 80 | Reverse Proxy |
| Postgres | kontakte-postgres | 5432 | Datenbank |
| PostgREST | kontakte-postgrest | 3000 | REST API |
| GoTrue | kontakte-gotrue | 9999 | Authentication |
| Realtime | kontakte-realtime | 4000 | WebSockets |
| Storage | kontakte-storage | 5000 | File Management |
| imgproxy | kontakte-imgproxy | 5001 | Image Transform |
| Studio | kontakte-studio | 3000 | Admin UI |

**Zugriff von außen (über Traefik):**
- `/studio` → Supabase Studio
- `/api` → PostgREST API
- `/auth` → GoTrue Auth
- `/realtime` → Realtime WS
- `/storage` → Storage API

---

## 🔐 Sicherheit

### Generierte Passwörter

Das Deploy-Script generiert automatisch:
- **POSTGRES_PASSWORD** – 32 Zeichen
- **JWT_SECRET** – Base64-encoded

Gespeichert in: `/share/Public/fvw/.env`

```bash
# Passwörter anzeigen
cat .env | grep PASSWORD
cat .env | grep JWT
```

### Firewall

Empfohlen für Produktionseinsatz:

```bash
# Nur Port 80 von außen erreichbar
# QNAP: Systemsteuerung → Sicherheit → Firewall
# Regel: TCP Port 80 erlauben, Rest blockieren
```

### Backup

```bash
# Manuelles Datenbank-Backup
docker compose exec postgres pg_dump -U postgres kontakte > backup_$(date +%Y%m%d).sql

# Wiederherstellen
docker compose exec -T postgres psql -U postgres kontakte < backup_20260211.sql
```

---

## ❓ FAQ

### Wo ist das Frontend?

**Aktueller Stand:** Das Web-Frontend (`apps/web`) ist noch in Entwicklung und in der `docker-compose.yml` auskommentiert.

**Später verfügbar unter:** `http://deine-qnap-ip/` (Traefik Root)

### Wie greife ich auf die Datenbank zu?

**Option 1: Supabase Studio**
- `http://deine-qnap-ip/studio`
- Grafische Oberfläche

**Option 2: psql CLI**
```bash
docker compose exec postgres psql -U postgres -d kontakte
```

**Option 3: Externe Tools (z.B. pgAdmin)**
- Host: `deine-qnap-ip`
- Port: `5432`
- User: `postgres`
- Password: (siehe `.env`)
- Database: `kontakte`

### Wie erstelle ich Tabellen?

Aktuell manuell über Supabase Studio:

1. Öffne Studio → Table Editor
2. "New Table" klicken
3. Schema definieren
4. Speichern

Oder via SQL Editor im Studio.

---

## 📞 Support

- **GitHub Repository:** [thomaslutzkolter/fvw](https://github.com/thomaslutzkolter/fvw)
- **Supabase Docs:** [supabase.com/docs](https://supabase.com/docs)
- **QNAP Container Station:** [QNAP Support](https://www.qnap.com/go/software/container-station)

---

## 📝 Changelog

- **2026-02-11:** Production-ready QNAP deployment
  - wget-basierte Installation (kein Git erforderlich)
  - Port 8080 Konflikt behoben (Traefik Dashboard entfernt)
  - Migrations-Volume entfernt (Permission-Fix)
  - Studio Image auf `:latest` aktualisiert
  - Backend-Only (Frontend folgt später)

---

**Viel Erfolg mit deinem FVW Backend! 🚀**
