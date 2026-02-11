# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install

# Copy source
COPY . .

# Build for production
RUN npm run build

# Production Stage (Nginx)
FROM nginx:alpine

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Script to inject env vars at runtime
COPY <<EOF /docker-entrypoint.d/40-env-config.sh
#!/bin/sh
cat <<JS > /usr/share/nginx/html/config.js
window.__env__ = {
  VITE_SUPABASE_URL: "\${NEXT_PUBLIC_SUPABASE_URL}",
  VITE_SUPABASE_ANON_KEY: "\${NEXT_PUBLIC_SUPABASE_ANON_KEY}"
};
JS
EOF

RUN chmod +x /docker-entrypoint.d/40-env-config.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
