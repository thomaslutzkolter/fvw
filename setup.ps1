# =================================
# FVW KONTAKTVERWALTUNG
# Automatisches Setup für Windows
# =================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  FVW Kontaktverwaltung - Auto Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# =================================
# 1. Prüfe Docker
# =================================
Write-Host "🔍 Prüfe Docker..." -ForegroundColor Yellow

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker ist nicht installiert!" -ForegroundColor Red
    Write-Host "Installiere Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Prüfe ob Docker läuft
try {
    docker info | Out-Null
}
catch {
    Write-Host "❌ Docker läuft nicht!" -ForegroundColor Red
    Write-Host "Starte Docker Desktop und führe dieses Script erneut aus." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Docker läuft" -ForegroundColor Green

# =================================
# 2. Automatische Environment-Konfiguration
# =================================
Write-Host ""
Write-Host "⚙️  Erstelle Environment..." -ForegroundColor Yellow

# Generiere sichere Passwörter
function Generate-Password {
    $bytes = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
    return [Convert]::ToBase64String($bytes).Substring(0, 32)
}

$POSTGRES_PW = Generate-Password
$JWT_SECRET = Generate-Password

# Hole lokale IP (LAN-Adresse)
$LOCAL_IP = $null

# Versuche verschiedene Interface-Namen
$interfacePatterns = @("Ethernet*", "WLAN*", "Wi-Fi*", "*LAN*")
foreach ($pattern in $interfacePatterns) {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $pattern -ErrorAction SilentlyContinue | 
        Where-Object { $_.IPAddress -match "^192\.168\.|^10\.|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-1]\." } | 
        Select-Object -First 1).IPAddress
    if ($ip) {
        $LOCAL_IP = $ip
        break
    }
}

# Fallback auf erste nicht-localhost IPv4
if (-not $LOCAL_IP) {
    $LOCAL_IP = (Get-NetIPAddress -AddressFamily IPv4 | 
        Where-Object { $_.IPAddress -ne "127.0.0.1" } | 
        Select-Object -First 1).IPAddress
}

# Letzter Fallback
if (-not $LOCAL_IP) {
    $LOCAL_IP = "localhost"
    Write-Host "⚠️  Konnte LAN-IP nicht ermitteln, nutze localhost" -ForegroundColor Yellow
}

# Erstelle .env
$envContent = @"
# =================================
# AUTO-GENERIERT - NICHT MANUELL EDITIEREN
# =================================

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
HOST_IP=$LOCAL_IP
PUBLIC_PORT=80

# SMTP (optional)
SMTP_ADMIN_EMAIL=admin@example.com
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_SENDER_NAME=FVW Kontaktverwaltung

# Frontend
NEXT_PUBLIC_SUPABASE_URL=http://$LOCAL_IP/api
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

NODE_ENV=development
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "✅ .env erstellt" -ForegroundColor Green
Write-Host "   Postgres: $POSTGRES_PW" -ForegroundColor Gray
Write-Host "   Host IP: $LOCAL_IP" -ForegroundColor Gray

# =================================
# 3. Erstelle Verzeichnisse
# =================================
Write-Host ""
Write-Host "📁 Erstelle Verzeichnisse..." -ForegroundColor Yellow

New-Item -ItemType Directory -Force -Path "volumes/postgres" | Out-Null
New-Item -ItemType Directory -Force -Path "volumes/storage" | Out-Null

Write-Host "✅ Verzeichnisse erstellt" -ForegroundColor Green

# =================================
# 4. Starte Docker Stack
# =================================
Write-Host ""
Write-Host "🚀 Starte Supabase Stack..." -ForegroundColor Yellow
Write-Host "   (Erster Start dauert ~2 Minuten wegen Image-Downloads)" -ForegroundColor Gray
Write-Host ""

docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Compose Start fehlgeschlagen!" -ForegroundColor Red
    exit 1
}

# =================================
# 5. Warte auf Services
# =================================
Write-Host ""
Write-Host "⏳ Warte auf Services..." -ForegroundColor Yellow

Start-Sleep -Seconds 5

# Warte auf Postgres
Write-Host -NoNewline "   Postgres: "
$retries = 0
while ($retries -lt 30) {
    $result = docker compose exec -T postgres pg_isready -U postgres 2>&1
    if ($result -match "accepting connections") {
        Write-Host "✅" -ForegroundColor Green
        break
    }
    Write-Host -NoNewline "." -ForegroundColor Gray
    Start-Sleep -Seconds 1
    $retries++
}

if ($retries -eq 30) {
    Write-Host " ❌ Timeout" -ForegroundColor Red
    Write-Host ""
    Write-Host "Prüfe Logs mit: docker compose logs postgres" -ForegroundColor Yellow
    exit 1
}

# Kurze Wartezeit für andere Services
Start-Sleep -Seconds 5

# =================================
# 6. Fertig!
# =================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  ✅ Setup erfolgreich abgeschlossen!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Services sind erreichbar unter:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   🌐 Web-App:         http://$LOCAL_IP" -ForegroundColor White
Write-Host "   🗄️  Supabase Studio: http://$LOCAL_IP/studio" -ForegroundColor White
Write-Host "   🔌 REST API:        http://$LOCAL_IP/api" -ForegroundColor White
Write-Host "   📊 Traefik:         http://$LOCAL_IP`:8080" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Nächste Schritte:" -ForegroundColor Yellow
Write-Host "   1. Öffne Studio:     http://$LOCAL_IP/studio" -ForegroundColor Gray
Write-Host "   2. Erstelle Account über Studio (Authentication)" -ForegroundColor Gray
Write-Host "   3. Entwickle Frontend:  cd apps\web && pnpm dev" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Zugriff von anderen Geräten im Netzwerk:" -ForegroundColor Cyan
Write-Host "   Verwende die gleichen URLs mit IP $LOCAL_IP" -ForegroundColor Gray
Write-Host "   (PC, iPhone, Laptop, etc.)" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 Stoppen:    docker compose down" -ForegroundColor Yellow
Write-Host "🔄 Logs:       docker compose logs -f" -ForegroundColor Yellow
Write-Host ""
