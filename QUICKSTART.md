# =================================
# FVW KONTAKTVERWALTUNG
# Quick Start Guide
# =================================

## 🚀 Initialer Setup (lokal)

### 1. Environment konfigurieren
cp .env.example .env

# Editiere .env und setze:
# - POSTGRES_PASSWORD (sicheres Passwort)
# - JWT_SECRET (generiere mit: openssl rand -base64 32)
# - HOST_IP (192.168.1.100 oder deine QNAP-IP)

### 2. Docker Stack starten
docker compose up -d

# Prüfe Status
docker compose ps

### 3. Warte auf Services (~30 Sekunden)
# Postgres initialisiert die Datenbank mit allen Migrationen

### 4. Zugriff auf Services

- Supabase Studio: http://localhost/studio
  (Datenbank-Management, SQL-Editor)

- REST API: http://localhost/api
  (Auto-generierte API aus DB-Schema)

- Web-App: http://localhost
  (Landing Page mit Status)

- Traefik Dashboard: http://localhost:8080
  (Routing-Übersicht)

### 5. Frontend entwickeln
cd apps/web
pnpm install
pnpm dev

# Frontend läuft auf http://localhost:3000

---

## 🗄️ Datenbank erkunden

1. Öffne Supabase Studio: http://localhost/studio

2. Navigiere zu "Table Editor"

3. Explore die Tabellen:
   - `contacts` - Haupttabelle mit 50+ Feldern
   - `contact_emails` - Mehrere E-Mails pro Kontakt
   - `contact_phones` - Mehrere Telefonnummern
   - `contact_addresses` - Strukturierte Adressen
   - `contact_versions` - Audit Trail
   - `contact_groups` - Gruppierung

4. SQL Editor testen:
```sql
-- Beispiel-Kontakt erstellen
INSERT INTO contacts (
  user_id,
  first_name,
  last_name,
  company,
  contact_type
) VALUES (
  auth.uid(),
  'Max',
  'Mustermann',
  'Beispiel GmbH',
  'business'
);

-- Alle Kontakte abrufen
SELECT * FROM get_contact_full(
  (SELECT id FROM contacts LIMIT 1)
);
```

---

## 📦 QNAP Deployment

### Variante A: Manuell

```bash
# 1. SSH auf QNAP
ssh admin@192.168.1.100

# 2. Repository klonen
cd /share/Public
git clone <repo-url> fvw
cd fvw

# 3. Environment konfigurieren
cp .env.example .env
nano .env  # Passe HOST_IP an

# 4. Starten
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 5. Logs prüfen
docker compose logs -f
```

### Automatisches Deployment (Empfohlen)

```bash
# 1. SSH auf QNAP
ssh admin@192.168.1.100

# 2. Repository holen
cd /share/Public
wget https://github.com/thomaslutzkolter/fvw/archive/refs/heads/main.zip
unzip main.zip
mv fvw-main fvw
rm main.zip
cd fvw

# 3. One-Shot Deployment
chmod +x deploy-qnap.sh
./deploy-qnap.sh

# Script macht:
# - IP-Erkennung (oder fragt nach)
# - Passwort-Generierung
# - Environment-Setup
# - Docker Compose Start
# - Health-Checks
```

**Services dann erreichbar unter Port 8081:**
- Studio: `http://qnap-ip:8081/studio`
- API: `http://qnap-ip:8081/api`

---

## 🛠️ Nützliche Commands

```bash
# Services neustarten
docker compose restart

# Logs anzeigen
docker compose logs -f postgres
docker compose logs -f postgrest

# Services stoppen
docker compose down

# Services + Volumes löschen (Daten werden gelöscht!)
docker compose down -v

# Nur bestimmten Service neustarten
docker compose restart postgres

# In Postgres-Container
docker compose exec postgres psql -U postgres -d kontakte

# Migrationen neu ausführen
docker compose down
docker volume rm fvw_postgres-data
docker compose up -d
```

---

## 🔍 Troubleshooting

### Problem: "Cannot connect to database"
```bash
# Prüfe ob Postgres läuft
docker compose exec postgres pg_isready

# Restart Postgres
docker compose restart postgres

# Warte 10 Sekunden, dann restart PostgREST
docker compose restart postgrest
```

### Problem: "PostgREST API nicht erreichbar"
```bash
# Prüfe Traefik-Routing
docker compose logs traefik | grep postgrest

# Restart PostgREST
docker compose restart postgrest
```

### Problem: "Studio zeigt keine Tabellen"
```bash
# Prüfe ob Migrationen gelaufen sind
docker compose exec postgres psql -U postgres -d kontakte -c "\dt"

# Falls leer, manuell ausführen
docker compose exec -T postgres psql -U postgres -d kontakte < services/supabase/migrations/001_initial_schema.sql
docker compose exec -T postgres psql -U postgres -d kontakte < services/supabase/migrations/002_functions.sql
```

---

## 📝 Nächste Schritte

1. ✅ Backend läuft (Postgres, API, Auth, Realtime)
2. ✅ Datenbank-Schema komplett
3. ⏳ Frontend-Entwicklung:
   - [ ] Supabase-Client Integration
   - [ ] Auth-Flow (Login/Register)
   - [ ] Kontaktliste
   - [ ] Kontakt-Detailansicht
   - [ ] Import-Wizard

4. ⏳ Import-Engine entwickeln:
   - [ ] CSV-Parser
   - [ ] vCard-Parser
   - [ ] Mapping-UI
   - [ ] Bulk-Import-API

5. ⏳ Offline-Sync:
   - [ ] IndexedDB-Integration
   - [ ] Service Worker
   - [ ] Sync-Queue

---

## 🆘 Support

Für Fragen oder Probleme:
- Prüfe Logs: `docker compose logs -f`
- Prüfe README.md
- Prüfe Implementation Plan
