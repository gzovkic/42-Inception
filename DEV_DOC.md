# DEV_DOC.md - Developer Documentation

## Overview

This document explains how to set up, build, and maintain the Inception infrastructure from a developer's perspective.

## Environment Setup from Scratch

### Prerequisites

Before starting, ensure you have:

```bash
# Check Docker version
docker --version    # Should be 20.10+

# Check Docker Compose version
docker-compose --version  # Should be 1.29+

# Verify you have the required tools
which git
which make
```

### Step 1: Clone and Navigate

```bash
git clone <repository-url> 42-Inception
cd 42-Inception
```

### Step 2: Configure Environment Variables

Edit or create `srcs/.env`:

```bash
cp srcs/.env.example srcs/.env  # If example exists
# OR manually create srcs/.env with:
DOMAIN_NAME=gzovkic.42.fr
SQL_DATABASE=wordpress
SQL_USER=wpuser
SQL_PASSWORD=pizza123
SQL_ROOT_PASSWORD=rootpizza123
SQL_HOST=mariadb
WP_TITLE=My WordPress Site
WP_ADMIN_USER=wppizzageheim
WP_ADMIN_PASSWORD=wppizzageheim
WP_ADMIN_EMAIL=admin@gzovkic.42.fr
WP_USER=wppizzanormal
WP_USER_PASSWORD=wppizzanormal
WP_USER_EMAIL=user@gzovkic.42.fr
```

### Step 3: Configure Secrets (Optional but Recommended)

Create `secrets/` directory with sensitive files:

```bash
mkdir -p secrets

# Store passwords separately
echo "pizza123" > secrets/db_password.txt
echo "rootpizza123" > secrets/db_root_password.txt
echo "wppizzageheim" > secrets/credentials.txt
```

**Important:** Add `secrets/` to `.gitignore`:

```bash
echo "secrets/" >> .gitignore
```

### Step 4: Configure Domain Name

Add to `/etc/hosts`:

```bash
# macOS/Linux
sudo nano /etc/hosts

# Add this line:
127.0.0.1 gzovkic.42.fr
```

### Step 5: Verify Setup

```bash
# Check all files exist
ls -la Makefile
ls -la srcs/docker-compose.yml
ls -la srcs/.env

# Check configuration
cat srcs/.env
```

## Building and Launching the Project

### Initial Build

```bash
# Build Docker images (first time - takes 2-5 minutes)
make build

# Verify images were created
docker images | grep srcs-
```

### Launching Services

```bash
# Start all services
make up

# Verify services are running
make ps

# Check initialization logs
make logs
```

### Verify Services are Healthy

```bash
# Check MariaDB
docker-compose -f srcs/docker-compose.yml exec mariadb \
  mariadb -uroot -prootpizza123 -e "SELECT 1;"

# Check WordPress
docker-compose -f srcs/docker-compose.yml exec wordpress \
  wp --allow-root option get siteurl

# Check NGINX
docker-compose -f srcs/docker-compose.yml exec nginx \
  nginx -t
```

## Container and Volume Management

### Common Docker Compose Commands

```bash
# View all services
docker-compose -f srcs/docker-compose.yml ps

# View service logs
docker-compose -f srcs/docker-compose.yml logs [service]

# Execute command in container
docker-compose -f srcs/docker-compose.yml exec [service] [command]

# Rebuild specific service
docker-compose -f srcs/docker-compose.yml up -d --build [service]

# Stop specific service
docker-compose -f srcs/docker-compose.yml stop [service]

# Restart specific service
docker-compose -f srcs/docker-compose.yml restart [service]

# View service dependencies
docker-compose -f srcs/docker-compose.yml config
```

### Working with Volumes

```bash
# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect srcs_wp_data
docker volume inspect srcs_db_data

# Backup volume data
docker run --rm -v srcs_wp_data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/wp_data.tar.gz -C /data .

# Clean up unused volumes
docker volume prune
```

### Accessing Container Shells

```bash
# Access MariaDB container
docker-compose -f srcs/docker-compose.yml exec mariadb bash

# Access WordPress container
docker-compose -f srcs/docker-compose.yml exec wordpress bash

# Access NGINX container
docker-compose -f srcs/docker-compose.yml exec nginx bash
```

## Data Storage and Persistence

### Volume Structure

```
Volumes (Docker-managed):
├── srcs_db_data       → /var/lib/mysql (MariaDB)
└── srcs_wp_data       → /var/www/html (WordPress)

Network:
└── srcs_inception     → Bridge network connecting all services
```

### Data Persistence Mechanism

1. **Named Volumes:** Docker automatically persists data
2. **Location:** Typically in `/var/lib/docker/volumes/`
3. **Lifecycle:**
   - Created when containers first run
   - Data persists after `make down`
   - Removed only with `make clean`

### Verifying Data Persistence

```bash
# Check database tables exist
docker-compose -f srcs/docker-compose.yml exec mariadb \
  mariadb -uroot -proot_password wordpress -e "SHOW TABLES;"

# Check WordPress files exist
docker-compose -f srcs/docker-compose.yml exec wordpress \
  ls -la /var/www/html/
```

## Debugging and Troubleshooting

### Enable Verbose Logging

```bash
# View real-time logs
make logs

# Follow specific service
docker-compose -f srcs/docker-compose.yml logs -f [service]

# View last N lines
docker-compose -f srcs/docker-compose.yml logs --tail=50
```

### Check Container Health

```bash
# Get detailed container info
docker-compose -f srcs/docker-compose.yml ps -a

# Inspect container
docker inspect srcs-mariadb
docker inspect srcs-wordpress
docker inspect srcs-nginx

# View container resource usage
docker stats
```

### Common Issues and Solutions

#### Database Won't Connect

```bash
# Check MariaDB logs
make logs mariadb

# Verify database is accepting connections
docker-compose -f srcs/docker-compose.yml exec mariadb \
  mariadb -uroot -proot_password -e "SHOW PROCESSLIST;"

# Restart database
make restart
```

#### WordPress Installation Fails

```bash
# Check WordPress logs
make logs wordpress

# Verify PHP-FPM is running
docker-compose -f srcs/docker-compose.yml exec wordpress \
  ps aux | grep php-fpm

# Verify network connectivity to MariaDB
docker-compose -f srcs/docker-compose.yml exec wordpress \
  nc -zv mariadb 3306
```

#### NGINX Configuration Issues

```bash
# Test NGINX config
docker-compose -f srcs/docker-compose.yml exec nginx \
  nginx -t

# View NGINX error logs
make logs nginx

# Check SSL certificate
docker-compose -f srcs/docker-compose.yml exec nginx \
  openssl x509 -in /etc/nginx/ssl/inception.crt -text -noout
```

### Network Debugging

```bash
# Check if services can reach each other
docker-compose -f srcs/docker-compose.yml exec wordpress \
  ping mariadb

# Test port connectivity
docker-compose -f srcs/docker-compose.yml exec wordpress \
  curl -k https://nginx:443/

# List network interfaces
docker-compose -f srcs/docker-compose.yml exec wordpress \
  ip addr
```

## Modifying the Infrastructure

### Updating a Dockerfile

1. Edit the relevant Dockerfile
2. Rebuild the service:
   ```bash
   docker-compose -f srcs/docker-compose.yml up -d --build [service]
   ```

### Updating Environment Variables

1. Edit `srcs/.env`
2. Restart services:
   ```bash
   make restart
   ```

### Adding a New Service

1. Create service directory: `srcs/requirements/[service_name]/`
2. Create `Dockerfile` in that directory
3. Add service to `srcs/docker-compose.yml`
4. Add volume definitions if needed
5. Run: `make build` then `make up`

## File Locations and Data Flow

### Configuration Files

```
srcs/
├── .env                           # Environment variables
├── docker-compose.yml             # Service definitions
└── requirements/
    ├── mariadb/
    │   ├── Dockerfile             # MariaDB image
    │   ├── conf/50-server.cnf     # Database config
    │   └── tools/init.sh           # Startup script
    ├── wordpress/
    │   ├── Dockerfile             # WordPress + PHP-FPM image
    │   ├── conf/                  # PHP config
    │   └── tools/setup.sh          # Installation script
    └── nginx/
        ├── Dockerfile             # NGINX image
        ├── conf/nginx.conf        # Web server config
        └── tools/                 # Helper scripts
```

### Data Flow

```
Internet (HTTPS:443)
    ↓
Host Machine (/etc/hosts → 127.0.0.1)
    ↓
NGINX Container (Port 443)
    ↓
WordPress Container (Port 9000 - internal)
    ↓
MariaDB Container (Port 3306 - internal)
    ↓
db_data Volume (/var/lib/mysql)
```

## Performance Optimization

### Build Performance

```bash
# Use BuildKit for faster builds (experimental)
export DOCKER_BUILDKIT=1
make build

# Clean up unused images after changes
docker image prune
```

### Runtime Performance

```bash
# Monitor resource usage
docker stats

# Limit container resources
# (Edit docker-compose.yml and add resource limits)
```

### Volume Performance

For macOS/Docker Desktop users experiencing slow I/O:
- Named volumes are faster than bind mounts
- Avoid large file operations in volumes during development

## Deployment Checklist

Before considering this for production:

- [ ] Change default credentials in `.env`
- [ ] Use proper SSL certificates (not self-signed)
- [ ] Implement Docker Secrets for sensitive data
- [ ] Set resource limits in docker-compose.yml
- [ ] Configure proper logging (not console output)
- [ ] Set up backups for database and files
- [ ] Implement monitoring and health checks
- [ ] Use environment-specific configurations
- [ ] Secure the host machine
- [ ] Plan for scaling

## Development Workflow

### Making Changes

```bash
# 1. Stop current services
make down

# 2. Make changes (Dockerfile, configs, etc.)

# 3. Rebuild and start
make build
make up

# 4. Verify changes
make logs
make ps
```

### Testing Changes

```bash
# Test WordPress functionality
docker-compose -f srcs/docker-compose.yml exec wordpress \
  wp --allow-root post list

# Test database changes
docker-compose -f srcs/docker-compose.yml exec mariadb \
  mariadb -uroot -proot_password wordpress

# Test web requests
curl -k https://gzovkic.42.fr
```

## Useful Development Commands

```bash
# Quick status
make ps

# Real-time logs
make logs

# Enter a container shell
docker-compose -f srcs/docker-compose.yml exec [service] bash

# Full system restart
make restart

# Clean everything (careful - removes volumes!)
make clean

# View docker-compose configuration
docker-compose -f srcs/docker-compose.yml config

# Validate docker-compose.yml syntax
docker-compose -f srcs/docker-compose.yml config --quiet
```

## References

- Docker Compose Documentation: https://docs.docker.com/compose/
- Docker Best Practices: https://docs.docker.com/develop/dev-best-practices/
- MariaDB Documentation: https://mariadb.com/kb/en/
- WordPress Development: https://developer.wordpress.org/
- NGINX Documentation: https://nginx.org/en/docs/

## Support

For issues not covered here:
1. Check logs: `make logs`
2. Review error messages carefully
3. Verify all files exist in correct locations
4. Try `make clean && make all`
5. Check the project README.md for additional context
