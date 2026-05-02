FROM nginx:alpine

# Install tools
RUN apk add --no-cache curl

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy nginx template
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Copy frontend files
COPY . /usr/share/nginx/html

# Set default backend (Docker)
ENV BACKEND_HOST=backend

# Create necessary directories and fix permissions for non-root execution
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html /etc/nginx/conf.d /var/cache/nginx /var/run /var/log/nginx /etc/nginx/templates

USER nginx

# Expose unprivileged port
EXPOSE 8080

# Healthcheck
HEALTHCHECK CMD curl -f http://localhost:8080/_health || exit 1

# Start nginx with env substitution
CMD ["sh", "-c", "envsubst '$BACKEND_HOST' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off; pid /tmp/nginx.pid;'"]