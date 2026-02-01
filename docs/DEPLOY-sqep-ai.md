# Deploy SQEP-Zero on Your Own Server (sqep.ai)

This guide sets up Nginx as the front door, with Axum (Rust) on :8080 and Node/Express on :8090, both managed by systemd. TLS via Let's Encrypt.

---

## 0) DNS
Point your domain to the server IP:
- A  sqep.ai -> <SERVER_IP>
- AAAA sqep.ai -> <SERVER_IPV6> (if available)

---

## 1) Server Prep (Ubuntu 22.04/24.04)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git curl ufw jq
# Rust & Node (one-time)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
# Nginx & Certbot
sudo apt install -y nginx
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

Firewall (optional but recommended):
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

---

## 2) Fetch & Build
```bash
# clone your repo
git clone <YOUR_REPO_URL> sqep-zero
cd sqep-zero

# build Rust
cargo build --release

# install web deps
cd web && npm i && cd ..
```

---

## 3) Runtime Layout
Assume:
- Binary: /opt/sqep-zero/bin/sqep-zero
- Web root: /opt/sqep-zero/web (served by Node at :8090)
- Work dir: /opt/sqep-zero

```bash
sudo mkdir -p /opt/sqep-zero/bin /opt/sqep-zero/web /var/log/sqep
sudo cp target/release/sqep-zero /opt/sqep-zero/bin/
sudo cp -r web/* /opt/sqep-zero/web/
sudo chown -R root:root /opt/sqep-zero
```

Optional .env (for ports/config):
```bash
sudo tee /opt/sqep-zero/.env >/dev/null <<'ENV'
RUST_LOG=info
AXUM_ADDR=0.0.0.0:8080
WEB_ADDR=0.0.0.0:8090
CORS_ORIGINS=https://sqep.ai,http://localhost:8090
ENV
```

---

## 4) systemd Services

Rust API /etc/systemd/system/sqep-api.service
```ini
[Unit]
Description=SQEP-Zero Axum API
After=network.target

[Service]
User=www-data
Group=www-data
EnvironmentFile=-/opt/sqep-zero/.env
WorkingDirectory=/opt/sqep-zero
ExecStart=/opt/sqep-zero/bin/sqep-zero
Restart=always
RestartSec=3
StandardOutput=append:/var/log/sqep/api.out.log
StandardError=append:/var/log/sqep/api.err.log
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

Web (Node/Express) /etc/systemd/system/sqep-web.service
```ini
[Unit]
Description=SQEP-Zero Web (Node/Express)
After=network.target

[Service]
User=www-data
Group=www-data
EnvironmentFile=-/opt/sqep-zero/.env
WorkingDirectory=/opt/sqep-zero/web
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=3
StandardOutput=append:/var/log/sqep/web.out.log
StandardError=append:/var/log/sqep/web.err.log
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

Enable & start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now sqep-api.service sqep-web.service
sudo systemctl status sqep-api.service sqep-web.service
```

---

## 5) Nginx

Server block: /etc/nginx/sites-available/sqep.ai
```nginx
server {
  listen 80;
  listen [::]:80;
  server_name sqep.ai;

  location /.well-known/acme-challenge/ { root /var/www/html; }

  # Proxy to Node (web, static, chat, qtv, sz)
  location / {
    proxy_pass http://127.0.0.1:8090;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  # API -> Axum
  location /api/ {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Enable and test:
```bash
sudo ln -s /etc/nginx/sites-available/sqep.ai /etc/nginx/sites-enabled/sqep.ai
sudo nginx -t && sudo systemctl reload nginx
```

---

## 6) TLS (Let's Encrypt)
```bash
sudo certbot --nginx -d sqep.ai
# Choose redirect -> YES (force HTTPS)
```

Certs auto-renew via system timer. You can dry-run:
```bash
sudo certbot renew --dry-run
```

---

## 7) Health, Logs & Rotation

Basic checks:
```bash
curl -I https://sqep.ai/
curl -s https://sqep.ai/api/v1/health || true   # if you add a health route
journalctl -u sqep-api -n 200 --no-pager
journalctl -u sqep-web -n 200 --no-pager
```

Optional logrotate /etc/logrotate.d/sqep:
```
/var/log/sqep/*.log {
  weekly
  rotate 8
  compress
  missingok
  notifempty
  copytruncate
}
```

---

## 8) Security Hardening (Quick Wins)
- Create a dedicated user (instead of www-data) with limited permissions.
- Consider fail2ban (protect SSH & Nginx).
- Keep system patched (unattended-upgrades).
- Validate CORS origins strictly to https://sqep.ai in production.

---

## 9) Zero-Downtime Updates
```bash
# pull changes, rebuild, copy binaries
git pull
cargo build --release
sudo systemctl restart sqep-api.service
sudo systemctl restart sqep-web.service
# or use ExecReload with a wrapper that does graceful restarts
```

---

## 10) Optional: Docker Compose (alt deployment)

```yaml
version: "3.9"
services:
  api:
    image: ghcr.io/you/sqep-zero:latest
    ports: ["8080:8080"]
    environment:
      - RUST_LOG=info
  web:
    image: ghcr.io/you/sqep-web:latest
    ports: ["8090:8090"]
  nginx:
    image: nginx:stable
    ports: ["80:80","443:443"]
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certs:/etc/letsencrypt
    depends_on: [api, web]
```

---

## Post-Deploy Checklist
- https://sqep.ai serves the UI
- https://sqep.ai/api/v0/* responds
- EN/FR toggle persists
- QTV plays HLS and QSeed runs smoothly
- Logs are clean and rotating
