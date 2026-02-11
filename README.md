# FVW Kontaktverwaltung

Enterprise Contact Management mit Supabase Backend und modernem Frontend.

---

## 🚀 Quick Start (1 Befehl!)

```powershell
# Alles automatisch starten
.\setup.ps1
```

**Das Script macht:**
- ✅ Prüft Docker
- ✅ Generiert sichere Passwörter
- ✅ Erstellt `.env` automatisch
- ✅ Startet alle Services
- ✅ Wartet bis alles ready ist
- ✅ Zeigt URLs an

**Fertig!** Öffne: `http://localhost/studio`

---

## 📦 QNAP Deployment

```bash
# 1. SSH auf QNAP
ssh admin@qnap-ip

# 2. Repository klonen
cd /share/Docker
git clone <repo-url> fvw
cd fvw

# 3. Setup-Script ausführen
chmod +x deploy-qnap.sh
./deploy-qnap.sh
```

---

## 🛠️ Services

- **Studio**: `http://localhost/studio` (DB-Management)
- **API**: `http://localhost/api` (REST API)  
- **Web**: `http://localhost` (Frontend)
- **Traefik**: `http://localhost:8080` (Routing)

---

## 📊 Features

✅ **50+ Kontaktfelder** (Titel, Adelstitel, Anreden)  
✅ **Multi-Import** (CSV, vCard, JSON, Excel)  
✅ **Versionierung** (Vollständiger Audit Trail)  
✅ **Local-First Sync** (Offline-fähig)  
✅ **Enterprise Design** (FVW Branding)

---

## 🛑 Commands

```powershell
# Stoppen
docker compose down

# Logs anzeigen
docker compose logs -f

# Neustart
docker compose restart

# Alles löschen (inkl. Daten!)
docker compose down -v
```

---

## 📚 Dokumentation

- [QUICKSTART.md](./QUICKSTART.md) - Detaillierte Anleitung
- [Walkthrough](C:\Users\PC\.gemini\antigravity\brain\2768ada0-9d96-474a-ac2b-47da35d1a817\walkthrough.md) - Setup-Details

---

## 🏗️ Projekt-Struktur

```
fvw/
├── apps/web/              # Next.js Frontend
├── packages/              # Shared Packages
├── services/supabase/     # DB Migrationen
├── docker-compose.yml     # Services
└── setup.ps1             # Auto-Setup
```

---

**FVW Enterprise** • Built with Supabase & Next.js
