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
- ✅ Erkennt lokale IP (z.B. 192.168.1.50)
- ✅ Erstellt `.env` automatisch
- ✅ Startet alle Services
- ✅ Wartet bis alles ready ist
- ✅ Zeigt URLs mit lokaler IP

**Fertig!** Zugriff von **jedem Gerät im Netzwerk** via lokale IP!

---

## 📦 QNAP Deployment (One-Shot)

```bash
# 1. SSH auf QNAP
ssh admin@qnap-ip

# 2. Repository klonen
cd /share/Public
rm -rf fvw
wget https://github.com/thomaslutzkolter/fvw/archive/refs/heads/main.zip
unzip -o main.zip && mv fvw-main fvw && rm main.zip
cd fvw
sh deploy-qnap.sh
```

Dann erreichbar auf `http://<qnap-ip>:8081`

**Services erreichbar unter** (Port 8081):
- 🗄️ Supabase Studio: `http://qnap-ip:8081/studio`
- 🔌 API: `http://qnap-ip:8081/api`

---

## 🛠️ Services

Nach Setup erreichbar über **lokale IP** (z.B. `192.168.1.50`):

- **Studio**: `http://192.168.1.50/studio` (DB-Management)
- **API**: `http://192.168.1.50/api` (REST API)  
- **Web**: `http://192.168.1.50` (Frontend)
- **Traefik**: `http://192.168.1.50:8080` (Routing)

✅ Von **allen Geräten** im Netzwerk erreichbar (PC, Laptop, iPhone, Android)

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
