# 🚀 QNAP Deployment

## Einmalige Installation

```bash
# 1. SSH auf QNAP (ersetze IP mit deiner QNAP-IP)
ssh admin@192.168.1.100

# 2. Navigiere zu Docker-Verzeichnis
cd /share/Docker

# 3. Clone dein GitHub Repo (ersetze USERNAME mit deinem GitHub-Namen)
git clone https://github.com/USERNAME/fvw.git
cd fvw

# 4. Setup-Script ausführen (macht ALLES automatisch!)
chmod +x deploy-qnap.sh
./deploy-qnap.sh
```

**Fertig!** 🎉

---

## Nach dem Setup

Services sind erreichbar unter (ersetze IP mit deiner QNAP-IP):

- 🗄️ **Supabase Studio**: `http://192.168.1.100/studio`
- 🌐 **Web-App**: `http://192.168.1.100`
- 🔌 **API**: `http://192.168.1.100/api`

**Von allen Geräten im Netzwerk!** (PC, Laptop, iPhone, Android)

---

## Management

```bash
# Logs anzeigen
docker compose logs -f

# Services neustarten
docker compose restart

# Stoppen
docker compose down

# Status prüfen
docker compose ps
```

---

## Updates vom GitHub Repo

```bash
cd /share/Docker/fvw
git pull
docker compose down
docker compose up -d
```

---

## Troubleshooting

**Services laufen nicht?**
```bash
# Prüfe Status
docker compose ps

# Prüfe Logs
docker compose logs postgres
docker compose logs postgrest
```

**Port 80 bereits belegt?**
```bash
# Nutze anderen Port (z.B. 8081)
# Editiere .env:
PUBLIC_PORT=8081

# Neustart
docker compose down
docker compose up -d
```

---

## Voraussetzungen

- ✅ QNAP mit Container Station installiert
- ✅ SSH-Zugriff aktiviert
- ✅ Mindestens 2GB freier RAM
- ✅ Port 80 frei (oder anderen Port wählen)
