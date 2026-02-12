#!/bin/bash
set -e

# ==========================================
# FVW Consolidated Deployment Script for QNAP
# ==========================================

# 1. Setup Environment Variables
echo "🔧 Configuring environment..."

# Detect Host IP
HOST_IP=$(ip route get 1 | awk '{print $7}' | head -1)
echo "Detected Host IP: $HOST_IP"

# Security Keys (Generate if not present, but for now hardcoded for stability as requested)
JWT_SECRET="super-secret-jwt-token-with-at-least-32-characters-long"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU"
POSTGRES_PASSWORD="postgres_secure_password"

# Write .env file
cat > .env <<EOF
HOST_IP=$HOST_IP
PUBLIC_PORT=8081
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=kontakte
JWT_SECRET=$JWT_SECRET
ANON_KEY=$ANON_KEY
SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY
SMTP_ADMIN_EMAIL=admin@example.com
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=admin
SMTP_PASS=password
SMTP_SENDER_NAME=FVW
EOF

echo "✅ .env file generated."

# 2. Cleanup Old Deployment
echo "🧹 Cleaning up old containers..."
docker compose down -v --remove-orphans || true

# 3. Build Frontend
echo "🏗️ Building Frontend Image..."
# Ensure permissions for build context
chmod -R 777 apps/web || true
# Build with proper context
HOME=/tmp docker build -t fvw-web:local apps/web

# 4. Start Services
echo "🚀 Starting Services..."
docker compose --env-file .env up -d

# 5. Wait for Database
echo "⏳ Waiting for Database to be ready..."
sleep 15
until docker exec kontakte-postgres pg_isready -U postgres; do
  echo "Waiting for postgres..."
  sleep 5
done

# 6. Run Migrations
echo "📦 Running Migrations..."
# Exec into postgres container to run psql commands
# We map the migrations via a temporary container or just pipe them if possible. 
# Since we didn't mount migrations in docker-compose for postgres service (it just uses data volume),
# we will use docker exec -i to pipe the files.

APP_MIGRATION_FILE="services/supabase/migrations/001_initial_schema.sql"
FUNC_MIGRATION_FILE="services/supabase/migrations/002_functions.sql"

if [ -f "$APP_MIGRATION_FILE" ]; then
    echo "Applying schema migration..."
    cat "$APP_MIGRATION_FILE" | docker exec -i kontakte-postgres psql -U postgres -d kontakte
else
    echo "❌ Migration file $APP_MIGRATION_FILE not found!"
fi

if [ -f "$FUNC_MIGRATION_FILE" ]; then
    echo "Applying functions migration..."
    cat "$FUNC_MIGRATION_FILE" | docker exec -i kontakte-postgres psql -U postgres -d kontakte
else
    echo "⚠️ Functions migration file not found."
fi

# 7. Grant Permissions to Anon Role (Crucial for Postgrest)
echo "xB4 Fixing Anon Permissions..."
docker exec kontakte-postgres psql -U postgres -d kontakte -c "
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
"

# 8. Reload PostgREST
echo "🔄 Reloading PostgREST..."
docker restart kontakte-postgrest

echo "============================================"
echo "✅ DEPLOYMENT COMPLETE"
echo "URL: http://$HOST_IP:8081"
echo "============================================"
