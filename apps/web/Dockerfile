# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
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
RUN echo '#!/bin/sh' > /docker-entrypoint.d/40-env-config.sh && \
  echo 'cat > /usr/share/nginx/html/config.js << EOF' >> /docker-entrypoint.d/40-env-config.sh && \
  echo 'window.__env__ = {' >> /docker-entrypoint.d/40-env-config.sh && \
  echo '  VITE_SUPABASE_URL: "${NEXT_PUBLIC_SUPABASE_URL}",' >> /docker-entrypoint.d/40-env-config.sh && \
  echo '  VITE_SUPABASE_ANON_KEY: "${NEXT_PUBLIC_SUPABASE_ANON_KEY}"' >> /docker-entrypoint.d/40-env-config.sh && \
  echo '};' >> /docker-entrypoint.d/40-env-config.sh && \
  echo 'EOF' >> /docker-entrypoint.d/40-env-config.sh && \
  chmod +x /docker-entrypoint.d/40-env-config.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
