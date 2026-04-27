*This project has been created as part of the 42 curriculum by gzovkic.*

# Inception - Docker Infrastructure Project

## Description

Inception is a system administration project that teaches Docker containerization through building a complete WordPress infrastructure. The project involves creating and orchestrating multiple Docker containers (NGINX, WordPress+PHP-FPM, MariaDB) with proper networking, volumes, and security configurations.

**Goal:** Set up a fully functional WordPress stack using Docker Compose with HTTPS support, persistent data storage, and proper service isolation.

## Instructions

### Prerequisites
- Docker and Docker Compose installed
- Unix-like system (Linux, macOS)
- Access to `/etc/hosts` for domain configuration

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd 42-Inception
   ```

2. **Configure the domain:**
   Add this line to `/etc/hosts`:
   ```
   127.0.0.1 gzovkic.42.fr
   ```

3. **Build and start the project:**
   ```bash
   make all
   ```

4. **Access the services:**
   - **Website:** https://gzovkic.42.fr
   - **WordPress Admin:** https://gzovkic.42.fr/wp-admin
   - **Username:** `wppizzageheim`
   - **Password:** `wppizzageheim`

### Available Commands

```bash
make build      # Build Docker images only
make up         # Start containers
make down       # Stop containers
make logs       # View container logs
make ps         # Show running containers
make restart    # Restart all services
make clean      # Remove everything (including volumes)
make help       # Show all available commands
```

## Project Architecture

### Services

1. **MariaDB** (Database)
   - Stores WordPress data
   - Port: 3306 (internal only)
   - Data volume: `db_data`

2. **WordPress + PHP-FPM**
   - Web application processing
   - Port: 9000 (internal only, communicates with NGINX)
   - Files volume: `wp_data`

3. **NGINX** (Web Server)
   - Reverse proxy, SSL/TLS termination
   - Port: 443 (HTTPS only)
   - TLS versions: 1.2 and 1.3

### Network Architecture

All services communicate through a private Docker bridge network (`inception`). NGINX is the only entry point accessible from the host.

```
Internet (HTTPS:443)
    ↓
NGINX Container
    ↓
WordPress Container ← → MariaDB Container
```

## Docker Concepts Explained

### Virtual Machines vs Docker

| Aspect | Virtual Machine | Docker Container |
|--------|-----------------|------------------|
| Size | 1-10 GB | 10-100 MB |
| Startup | Minutes | Seconds |
| OS | Full OS instance | Shared host OS kernel |
| Isolation | Complete | Process-level |
| Use Case | Heavy isolation | Lightweight, scalable |

**Why Docker?** Containers are lightweight, fast, and perfect for microservices. They don't require running full OS instances.

### Secrets vs Environment Variables

| Feature | Secrets | Environment Variables |
|---------|---------|----------------------|
| Storage | Mounted files in `/secrets/` | `.env` file |
| Security | Not exposed in image layers | Visible in containers |
| Use Case | Passwords, API keys | Non-sensitive config |

**Our choice:** Environment variables in `.env` for simplicity (school project). In production, use Docker Secrets.

### Docker Network vs Host Network

| Mode | Advantage | Disadvantage |
|------|-----------|--------------|
| **Bridge Network** | Services isolated, private communication | Extra layer |
| **Host Network** | Direct access, best performance | All services exposed, no isolation |

**Our choice:** Bridge network for security and service isolation.

### Docker Volumes vs Bind Mounts

| Type | Location | Use Case | Persistence |
|------|----------|----------|------------|
| **Named Volumes** | Docker-managed | Production data, databases | ✅ Yes |
| **Bind Mounts** | Host filesystem | Development, config files | ✅ Yes |

**Our choice:** Named volumes for database and WordPress files (as required by subject).

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [NGINX Documentation](https://nginx.org/en/docs/)

### Key Learning Resources
- Docker best practices: https://docs.docker.com/develop/dev-best-practices/
- PHP-FPM configuration: https://www.php.net/manual/en/install.fpm.php
- SSL/TLS setup: https://certbot.eff.org/

### AI Usage

AI was used to:
- **Debugging Docker configurations** - Helping understand and fix container communication issues
- **PHP-FPM setup** - Configuring PHP-FPM with NGINX
- **Script development** - Creating shell scripts for WordPress initialization and database setup
- **Documentation** - Structuring and explaining Docker concepts

## File Structure

```
42-Inception/
├── Makefile                 # Build automation
├── README.md               # This file
├── USER_DOC.md             # User documentation
├── DEV_DOC.md              # Developer documentation
├── secrets/                # Confidential data (gitignored)
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                # Environment variables
    ├── docker-compose.yml  # Service orchestration
    └── requirements/
        ├── mariadb/        # Database service
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── wordpress/      # Application service
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── nginx/          # Web server service
            ├── Dockerfile
            ├── conf/
            └── tools/
```

## Troubleshooting

**Containers won't start?**
```bash
make logs  # Check error messages
```

**Can't access website?**
- Verify `/etc/hosts` has `127.0.0.1 gzovkic.42.fr`
- Wait 10-15 seconds for WordPress to fully initialize
- Check NGINX logs: `docker-compose -f srcs/docker-compose.yml logs nginx`

**Database connection error?**
```bash
# Verify MariaDB is running
make ps

# Check database logs
docker-compose -f srcs/docker-compose.yml logs mariadb
```

## Security Notes

- SSL certificates are self-signed (acceptable for local development)
- Credentials in `.env` are for development only
- In production, use proper secrets management
- Admin username intentionally avoids "admin" (per requirements)

## License

This is a 42 School project. All rights reserved.
