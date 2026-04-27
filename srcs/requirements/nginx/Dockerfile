FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# SSL-Zertifikat generieren (Self-signed)
# Ersetze 'wil' durch deinen Login
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=DE/ST=BW/L=Heilbronn/O=42/OU=42/CN=wil.42.fr"

# Konfigurationsdatei kopieren
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# NGINX im Vordergrund starten
CMD ["nginx", "-g", "daemon off;"]