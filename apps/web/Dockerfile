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

# Create startup script with echo instead of heredoc
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'cat > /usr/share/nginx/html/config.js << "JSEOF"' >> /start.sh && \
    echo 'window.__env__ = {' >> /start.sh && \
    echo '  VITE_SUPABASE_URL: "${VITE_SUPABASE_URL:-http://localhost:54321}",' >> /start.sh && \
    echo '  VITE_SUPABASE_ANON_KEY: "${VITE_SUPABASE_ANON_KEY:-dummy-key}"' >> /start.sh && \
    echo '};' >> /start.sh && \
    echo 'JSEOF' >> /start.sh && \
    echo 'exec nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
