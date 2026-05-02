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

# Fix permissions
RUN chown -R nginx:nginx /usr/share/nginx/html

USER nginx

EXPOSE 80

# Healthcheck
HEALTHCHECK CMD curl -f http://localhost/_health || exit 1

# Start nginx with env substitution
CMD ["sh", "-c", "envsubst '$BACKEND_HOST' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]