# FVW Kontaktverwaltung

Enterprise Contact Management System mit vollständigem Supabase-Backend und modernem Frontend.

## 🏗️ Architektur

```
fvw/
├── apps/
│   └── web/              # Next.js Frontend (Enterprise UI)
├── packages/
│   ├── database-types/   # Generierte DB-Typen
│   ├── validation/       # Zod-Schemas
│   └── import-engine/    # CSV/vCard Import
├── services/
│   └── supabase/
│       └── migrations/   # Database Migrationen
├── docker-compose.yml    # Basis-Setup
├── docker-compose.prod.yml  # QNAP Production
└── deploy-qnap.sh        # One-Click Deployment
```

## 🚀 Schnellstart (Entwicklung)

```bash
# 1. Repository klonen
git clone <repo-url> fvw
cd fvw

# 2. Dependencies installieren
pnpm install

# 3. Environment konfigurieren
cp .env.example .env
# Editiere .env (Passwörter, QNAP-IP)

# 4. Supabase Stack starten
docker compose up -d

# 5. Prüfe Services
docker compose ps

# 6. Öffne Supabase Studio
open http://localhost/studio

# 7. Frontend entwickeln
cd apps/web
pnpm dev
```

## 📦 QNAP Deployment

```bash
# SSH auf QNAP
ssh admin@qnap-ip

# Repository klonen
cd /share/Docker
git clone <repo-url> fvw
cd fvw

# Deployment-Script ausführen
chmod +x deploy-qnap.sh
./deploy-qnap.sh

# Services sind erreichbar unter:
# - App:    http://qnap-ip
# - Studio: http://qnap-ip/studio
# - API:    http://qnap-ip/api
```

## 🗄️ Datenbank-Features

- **50+ Kontaktfelder**: Titel, Adelstitel, Anreden, Kategorien
- **Mehrere E-Mails/Telefone/Adressen** pro Kontakt
- **Flexible Custom Fields** für individuelle Felder
- **Automatische Versionierung** aller Änderungen
- **Full-Text-Search** mit Fuzzy-Matching
- **Duplikat-Erkennung** (Name, E-Mail, Firma)
- **Row Level Security** (User-Isolation)

## 📥 Import-Formate

- ✅ CSV (mit Feld-Mapping)
- ✅ vCard (.vcf)
- ✅ JSON
- ✅ Excel (.xlsx)

## 🔄 Synchronisation

- **Local-First**: IndexedDB Cache
- **Realtime Sync**: Supabase Realtime
- **Konfliktauflösung**: Last-Write-Wins + Versionierung
- **Später**: PWA, Outlook-Sync, CardDAV (iOS/Unix)

## 🛠️ Tech-Stack

### Backend
- **Supabase**: PostgreSQL, Auth, Realtime, Storage
- **Traefik**: Reverse Proxy
- **Docker Compose**: Container-Orchestrierung

### Frontend
- **Next.js 14**: App Router, RSC
- **TypeScript**: Strict Mode
- **TailwindCSS**: Modern Styling
- **shadcn/ui**: Enterprise UI-Komponenten
- **React Query**: Server-State Management
- **Zustand**: Client-State Management

## 📜 Scripts

```bash
# Entwicklung
pnpm dev              # Alle Apps im Dev-Mode
pnpm build            # Production Build
pnpm lint             # Linting
pnpm type-check       # TypeScript Check

# Docker
pnpm docker:dev       # Start Development Stack
pnpm docker:prod      # Start Production Stack (QNAP)
pnpm docker:stop      # Stop alle Container
pnpm docker:logs      # Logs anzeigen
```

## 🗂️ Datenbank-Schema

Siehe [migrations/001_initial_schema.sql](./services/supabase/migrations/001_initial_schema.sql)

**Haupttabellen:**
- `contacts` - Kern-Kontaktdaten
- `contact_emails` - E-Mail-Adressen
- `contact_phones` - Telefonnummern
- `contact_addresses` - Adressen (strukturiert)
- `contact_custom_fields` - Flexible Erweiterung
- `contact_versions` - Audit Trail
- `contact_groups` - Gruppierung
- `import_sessions` - Import-Tracking

## 🔐 Security

- **Row Level Security (RLS)**: User sieht nur eigene Daten
- **JWT Authentication**: Supabase Auth
- **HTTPS**: via Traefik (Production)
- **Environment-basiert**: Keine Secrets in Code

## 📝 Roadmap

- [x] Monorepo Setup
- [x] Docker Compose QNAP-Ready
- [x] Database Schema & Migrationen
- [ ] TypeScript Packages (Types, Validation, Import)
- [ ] Next.js Frontend (Enterprise UI)
- [ ] Import-Wizard UI
- [ ] Offline-First Sync
- [ ] PWA Support
- [ ] Native Sync (Outlook, iOS, Unix)

## 📄 Lizenz

Privat / Enterprise-Internal
