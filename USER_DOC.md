# USER_DOC.md - User Documentation

## Overview

This document explains how to use the Inception WordPress infrastructure as an end user or system administrator.

## What Services Are Provided?

The Inception stack provides a complete WordPress content management system with the following components:

### 1. **WordPress Website**
- Full-featured blogging and content management platform
- Accessible via secure HTTPS connection
- Located at: `https://gzovkic.42.fr`

### 2. **WordPress Administration Panel**
- Content management interface
- User management
- Theme and plugin management
- Located at: `https://gzovkic.42.fr/wp-admin`

### 3. **Database (MariaDB)**
- Stores all website content, users, and settings
- Runs in background (not directly accessible)
- Automatically managed by the system

### 4. **Web Server (NGINX)**
- Handles HTTPS traffic securely
- Routes requests to the WordPress application
- Provides SSL/TLS encryption

## Starting and Stopping the Project

### Start the Project

```bash
cd /Users/gabrijel/Desktop/42-Inception
make all
```

This will:
1. Build Docker images (first time only)
2. Create and start all containers
3. Initialize the WordPress database
4. Display a message when ready

**Wait 15-20 seconds** for WordPress to fully initialize before accessing the website.

### Stop the Project

```bash
make down
```

This will gracefully stop all services and preserve your data.

### Restart the Project

```bash
make restart
```

This will stop and restart all services.

## Accessing the Website and Admin Panel

### Access the Website

1. Make sure the project is running:
   ```bash
   make ps
   ```

2. Open your browser and navigate to:
   ```
   https://gzovkic.42.fr
   ```

3. **SSL Certificate Warning:** The first time you visit, your browser will warn about the self-signed certificate. Click "Advanced" → "Proceed" to continue. This is normal for local development.

### Access the WordPress Admin Panel

1. Navigate to:
   ```
   https://gzovkic.42.fr/wp-admin
   ```

2. Log in with the administrator credentials

## Managing Credentials

### Administrator Account

- **Username:** `wppizzageheim`
- **Password:** `wppizzageheim`
- **Email:** `admin@gzovkic.42.fr`

### Regular User Account

- **Username:** `wppizzanormal`
- **Password:** `wppizzanormal`
- **Email:** `user@gzovkic.42.fr`

### Database Access

Database credentials are stored in `srcs/.env`:

```
SQL_USER=wpuser
SQL_PASSWORD=pizza123
SQL_ROOT_PASSWORD=rootpizza123
```

⚠️ **Note:** These are for local development only. Keep them private!

### Changing Passwords

To change passwords after login:

1. **Admin Password:**
   - Log in to `/wp-admin`
   - Go to Users → Your Profile
   - Scroll down and set a new password

2. **Regular User Password:**
   - Log in as admin
   - Go to Users → All Users
   - Click on the user and set a new password

## Checking if Services Are Running Correctly

### Quick Status Check

```bash
make ps
```

This shows all running containers. You should see:
- **mariadb** - Running (port 3306)
- **wordpress** - Running (port 9000)
- **nginx** - Running (port 443)

### View Detailed Logs

```bash
make logs
```

This shows real-time logs from all services.

### Check Individual Service Logs

```bash
# MariaDB logs
docker-compose -f srcs/docker-compose.yml logs mariadb

# WordPress logs
docker-compose -f srcs/docker-compose.yml logs wordpress

# NGINX logs
docker-compose -f srcs/docker-compose.yml logs nginx
```

### Test Database Connection

```bash
# Connect to database container
docker-compose -f srcs/docker-compose.yml exec mariadb mariadb -uroot -p$MYSQL_ROOT_PASSWORD

# Show databases
SHOW DATABASES;

# Exit
EXIT;
```

### Test Website Connectivity

```bash
curl -k https://gzovkic.42.fr
```

## Troubleshooting Common Issues

### Issue: "Connection refused" when visiting website

**Solution:**
1. Check if containers are running: `make ps`
2. Wait 20 seconds for WordPress to initialize
3. Restart services: `make restart`
4. Check logs: `make logs | grep error`

### Issue: Database not initializing

**Solution:**
```bash
make down

make clean
make all
```

### Issue: SSL certificate error

**Solution:**
This is normal for self-signed certificates. In your browser:
1. Click "Advanced" or "Details"
2. Select "Proceed" or "Accept Risk"

### Issue: Can't log in to WordPress

**Solution:**
1. Clear browser cookies for `gzovkic.42.fr`
2. Try using the correct username/password (see credentials section)
3. Try accessing from a private/incognito window
4. Check database logs: `make logs | grep wordpress`

### Issue: Website files not updating

**Solution:**
Files are stored in a Docker volume. To verify files are persisted:

```bash
docker volume ls

docker volume inspect srcs_wp_data
```

## Data Persistence

### What Data Is Persisted?

- **WordPress files** - Website content, themes, plugins (in `wp_data` volume)
- **Database** - Posts, users, settings, comments (in `db_data` volume)

### Where Is Data Stored?

On your host machine, volumes are typically stored at:
```
/var/lib/docker/volumes/
```

### Backing Up Your Data

To save your WordPress data:

```bash
docker run --rm -v srcs_wp_data:/data -v $(pwd):/backup ubuntu \
  tar czf /backup/wordpress_backup.tar.gz -C /data .

docker-compose -f srcs/docker-compose.yml exec mariadb mariadb-dump \
  -uroot -p$MYSQL_ROOT_PASSWORD wordpress > wordpress_backup.sql
```

### Restoring Data

When you stop and restart the project:
- **All data persists automatically** (it's stored in volumes)
- No data loss occurs from normal stop/restart

## Performance Tips

1. **First startup:** Takes 20-30 seconds for database initialization
2. **Subsequent startups:** Faster (5-10 seconds)
3. **If slow:** Check system resources with `docker stats`
4. **Clean up:** Remove unused containers with `make clean`

## Getting Help

### Check Logs for Errors

```bash
make logs
```

### Restart Everything

```bash
make down
make up
```

### Complete Reset

```bash
make clean
make all
```

## Security Reminder

⚠️ This setup is for **local development only**. Do not use in production:
- Credentials are stored in plain text
- SSL certificate is self-signed
- Services are minimally hardened

For production use, implement proper security measures.
