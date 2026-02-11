# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Production Stage
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create env injection script
RUN cat > /docker-entrypoint.d/40-env-config.sh << 'EOF'
#!/bin/sh
set -e
cat > /usr/share/nginx/html/config.js << JSEOF
window.__env__ = {
VITE_SUPABASE_URL: "${VITE_SUPABASE_URL:-http://localhost:54321}",
VITE_SUPABASE_ANON_KEY: "${VITE_SUPABASE_ANON_KEY:-dummy-key}"
};
JSEOF
EOF

RUN chmod +x /docker-entrypoint.d/40-env-config.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
