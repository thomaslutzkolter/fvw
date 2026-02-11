#!/bin/sh
set -e

# Generate config.js with runtime environment variables
cat > /usr/share/nginx/html/config.js << EOF
window.__env__ = {
  VITE_SUPABASE_URL: "${VITE_SUPABASE_URL:-http://localhost:54321}",
  VITE_SUPABASE_ANON_KEY: "${VITE_SUPABASE_ANON_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0}"
};
EOF

echo "Generated config.js with VITE_SUPABASE_URL=${VITE_SUPABASE_URL:-http://localhost:54321}"

# Start nginx
exec nginx -g "daemon off;"
