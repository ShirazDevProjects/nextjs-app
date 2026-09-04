# VPS Deployment Guide with Docker & Traefik

This guide explains how to deploy your Next.js application to your VPS using Docker and your existing Traefik reverse proxy.

---

## 1. Prerequisites on your VPS

Ensure you have the following ready on your VPS:
- **Docker & Docker Compose** installed (`docker compose version`).
- **Traefik** is already running in a container.
- **DNS Record**: An `A` (or `AAAA`) record pointing your domain (e.g., `example.com`) to your VPS IP address.

---

## 2. Identify Your Traefik Configuration

Before starting the app, check two details from your running Traefik instance:

### A. Docker Network Name
Traefik communicates with containers over a shared Docker network. Run this command on your VPS to find it:
```bash
docker network ls
```
Common names are `traefik-net`, `traefik_default`, `traefik_public`, `web`, or `proxy`.

If your Traefik network doesn't exist yet, you can create it:
```bash
docker network create traefik-net
```

### B. Certificate Resolver Name
Check your Traefik static configuration file (`traefik.yml` or command flags in Traefik's `docker-compose.yml`) for the ACME certificate resolver name. Common names are:
- `letsencrypt`
- `myresolver`
- `le`

---

## 3. Deployment Steps

### Step 1: Clone / Copy the Project to your VPS
SSH into your VPS and clone your repository or copy your project folder:
```bash
git clone <your-repo-url> /opt/nextjs-app
cd /opt/nextjs-app
```

### Step 2: Configure Environment Variables
Copy `.env.example` to `.env` (or edit existing `.env`):
```bash
cp .env.example .env
nano .env
```

Update the values to match your production setup:
```dotenv
DOMAIN=example.com
TRAEFIK_NETWORK=traefik-net
TRAEFIK_CERT_RESOLVER=letsencrypt

NODE_ENV=production
PORT=3000

# Update API and Auth URLs to your domain
NEXT_PUBLIC_API_URL=https://example.com/api
BETTER_AUTH_URL=https://example.com
BETTER_AUTH_SECRET=generate_a_random_32_character_secret

# MongoDB Connection
MONGODB_URI=mongodb://...
```

### Step 3: Build & Start the Container
Run:
```bash
docker compose up -d --build
```

Docker will:
1. Multi-stage build the Next.js standalone application.
2. Start the `nextjs-app` container on the internal network and attach to your Traefik network.
3. Traefik will detect the container labels, automatically provision an SSL certificate via Let's Encrypt, and route HTTPS traffic to port `3000`.

---

## 4. Maintenance & Operations

### View Real-Time Logs
```bash
docker compose logs -f app
```

### Check Container Status
```bash
docker compose ps
```

### Deploy Updates (CI/CD or Manual)
Whenever you push code updates to your VPS repository:
```bash
git pull origin main
docker compose up -d --build
```
*(Docker will build the new image and perform a near-instant zero-downtime container swap)*.

### Stop Application
```bash
docker compose down
```

---

## 5. Troubleshooting Checklist

| Issue | Cause | Solution |
|---|---|---|
| **404 Page Not Found** | Domain mismatch in Traefik router rule | Verify `DOMAIN` in `.env` matches the hostname in your browser. |
| **502 Bad Gateway** | Traefik cannot reach the container network or port | Ensure `TRAEFIK_NETWORK` matches your Traefik network and the container is running (`docker compose ps`). |
| **SSL Certificate Error** | Certificate resolver name mismatch or DNS issue | Ensure `TRAEFIK_CERT_RESOLVER` matches the name in your Traefik config, and your DNS `A` record has propagated. |
| **Network not found error** | The external network specified in `docker-compose.yml` does not exist | Run `docker network ls` and update `TRAEFIK_NETWORK` in `.env`, or run `docker network create <network-name>`. |
