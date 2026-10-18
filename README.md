<div align="center">

# 🦀 Pterodactyl Rust Web Egg

**A Pterodactyl Egg for Rust web applications with Git deployment, cron jobs, SSL certificates, Cloudflare Tunnel and signed auto-updates.**

[![Latest Release](https://img.shields.io/github/v/release/Ym0T/pterodactyl-rust-web-egg?style=for-the-badge&logo=github&color=2ea44f)](https://github.com/Ym0T/pterodactyl-rust-web-egg/releases)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Ym0T/pterodactyl-rust-web-egg?style=for-the-badge&logo=github&color=yellow)](https://github.com/Ym0T/pterodactyl-rust-web-egg/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/Ym0T/pterodactyl-rust-web-egg?style=for-the-badge)](https://github.com/Ym0T/pterodactyl-rust-web-egg/commits/main)

[![Docker Image](https://img.shields.io/badge/ghcr.io-ym0t%2Fpterodactyl--rust--web--egg-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://github.com/Ym0T/pterodactyl-rust-web-egg/pkgs/container/pterodactyl-rust-web-egg)
[![Pterodactyl](https://img.shields.io/badge/Pterodactyl-Egg-0E4688?style=for-the-badge)](https://pterodactyl.io)
[![Rust](https://img.shields.io/badge/Rust-stable%20%7C%20nightly-B7410E?style=for-the-badge&logo=rust&logoColor=white)](#docker-images)
[![Architecture](https://img.shields.io/badge/arch-amd64-555555?style=for-the-badge&logo=linux&logoColor=white)](#docker-images)

</div>

<br>

## Table of Contents
- [Features](#features)
- [Docker Images](#docker-images)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Auto-Update System](#auto-update-system)
- [Git Module](#git-module)
- [Cronjob](#cronjob)
- [SSL Certificate with Certbot](#ssl-certificate-with-certbot)
- [Cloudflared Tunnel Tutorial](#-cloudflared-tunnel-tutorial)
- [Log Cleaner Module](#log-cleaner-module)
- [Project Structure](#project-structure)
- [Notes](#notes)
- [License](#license)

<br>

## Features

- 🦀 **Rust Toolchain**: Pre-installed Rust with cargo, clippy, and rustfmt
- 🔄 **Auto-Update**: Automatically checks for and applies signed updates via the open-source [GitHub Version API](https://github.com/Ym0T/github-version-api)
- 🌱 **Git Module**: Clones your app on installation and runs `git pull` on every start
- ⏰ **Cronjob**: Built-in cron engine for scheduled tasks
- 🔐 **Certbot**: Let's Encrypt certificates via DNS-01 challenge
- 🧹 **LogCleaner**: Cleans `/tmp` and old logs on startup
- 🌐 **Cloudflare Tunnel**: Secure tunnel with token validation

<br>

## Docker Images

| Image | Description |
|-------|-------------|
| `ghcr.io/ym0t/pterodactyl-rust-web-egg:stable` | **Recommended** - Stable Rust toolchain. Well-tested, reliable, 6-week release cycle. Best for production. |
| `ghcr.io/ym0t/pterodactyl-rust-web-egg:nightly` | Bleeding-edge Rust with latest features. Updated daily. Use for experimental features like unstable APIs. |

### When to use Nightly?
- You need features behind `#![feature(...)]` flags
- You want the latest performance improvements
- You're developing libraries that need to test against nightly
- You're experimenting with upcoming Rust features

For most production use cases, **stable** is recommended.

<br>

## Installation

1. Download the egg file (`pterodactyl-egg-rust-web.json`)
2. In your Pterodactyl panel, navigate to **Nests** in the sidebar
3. Import the egg under **Import Egg**
4. Create a new server and select the **Rust Web Application** egg
5. Choose the Docker image matching your desired Rust version (stable/nightly)
6. Fill in all required variables, including your startup command

<br>

## Environment Variables

### Application Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP_CMD` | `cargo run --release` | Command to start your Rust application |
| `GIT_REPO` | `` | Git repository that gets cloned into `app/` on installation (optional) |
| `GIT_BRANCH` | `` | Branch to clone and pull, empty for the default branch |
| `USERNAME` | `` | Git username for private repositories |
| `ACCESS_TOKEN` | `` | Git access token for private repositories |

### Module Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTOUPDATE_STATUS` | `1` | Enable auto-update checking |
| `AUTOUPDATE_FORCE` | `1` | Apply updates automatically (enabled by default) |
| `GIT_STATUS` | `0` | Run `git pull` in `app/` on every start |
| `CRON_STATUS` | `0` | Enable the cron engine |
| `CRON_CONFIG_FILE` | `/home/container/crontab` | Path to your crontab |
| `CERTBOT_STATUS` | `0` | Request a Let's Encrypt certificate on startup |
| `CERTBOT_EMAIL` | `` | Email address for Let's Encrypt |
| `CERTBOT_DOMAIN` | `` | Domain for the certificate |
| `CERTBOT_STAGING` | `0` | Use the Let's Encrypt staging server for testing |
| `CERTBOT_FORCE_RENEWAL` | `0` | Renew the certificate even if it is still valid |
| `CLOUDFLARED_STATUS` | `0` | Enable Cloudflare Tunnel |
| `CLOUDFLARED_TOKEN` | `` | Cloudflare Tunnel token |
| `LOGCLEANER_STATUS` | `1` | Enable log cleanup |
| `RUST_LOG` | `info` | Rust logging level (error, warn, info, debug, trace) |

### Using the Pterodactyl Port

Pterodactyl provides the allocated port via the `SERVER_PORT` environment variable. Your Rust application must read this variable to use the correct port.

**Example Implementation:**

```rust
let port = std::env::var("SERVER_PORT")
    .unwrap_or_else(|_| "3000".to_string())
    .parse::<u16>()
    .expect("SERVER_PORT must be a valid port number");

let addr = format!("0.0.0.0:{}", port);
```

**With Axum:**

```rust
use axum::Router;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let port = std::env::var("SERVER_PORT").unwrap_or_else(|_| "3000".into());
    let addr = format!("0.0.0.0:{}", port);

    let app = Router::new();
    let listener = TcpListener::bind(&addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

**With Actix-web:**

```rust
use actix_web::{App, HttpServer};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port: u16 = std::env::var("SERVER_PORT")
        .unwrap_or_else(|_| "3000".into())
        .parse()
        .expect("Invalid port");

    HttpServer::new(|| App::new())
        .bind(("0.0.0.0", port))?
        .run()
        .await
}
```

<br>

## Auto-Update System

The egg includes an intelligent auto-update system that keeps your installation current with the latest features and security updates.

### How it works:

- **Automatic Version Checking**: Uses the [GitHub Version API](https://github.com/Ym0T/github-version-api), hosted at `api.tavuru.de`, to check for new releases
- **Smart Differential Updates**: Downloads only changed files, not the entire codebase
- **Selective Updates**: Only updates core system files (modules, scripts)
- **User Data Protection**: Never touches your application code or user data
- **Signed Updates**: Every update package is signed. The updater checks the signature before installing anything and refuses packages that don't match
- **Self-Update Capability**: Can safely update its own update mechanism

### Update Behavior:

#### **Automatic Mode (Default)**
- `AUTOUPDATE_STATUS=1`, `AUTOUPDATE_FORCE=1`
- Automatically downloads and applies updates on startup
- Shows detailed progress during updates
- Creates backups before applying changes

#### **Conservative Mode**
- `AUTOUPDATE_STATUS=1`, `AUTOUPDATE_FORCE=0`
- Checks for updates and shows availability
- Shows version information and changelog
- Updates must be manually approved

#### **Disabled Mode**
- `AUTOUPDATE_STATUS=0`
- Skips all update operations
- Useful for production environments requiring manual updates

### Example Output:

```bash
[AutoUpdate] Current version: v1.0.0
[AutoUpdate] Latest version: v1.1.0
[AutoUpdate] Update available: v1.0.0 -> v1.1.0
[AutoUpdate] Update summary:
  Total changes: 8
  Files added: 2
  Files modified: 5
  Files removed: 1
[AutoUpdate] Update completed successfully
```

### What Gets Updated:

- ✅ **Module scripts** (modules/)
- ✅ **Core scripts** (start-modules.sh)
- ✅ **Documentation** (README.md, LICENSE)
- ❌ **Your Rust application** (app/, src/, Cargo.toml)
- ❌ **User data** (logs, data, databases)

<br>

## Git Module

- Put your repository URL into `GIT_REPO`. On installation it is cloned into `app/`
- For private repositories also set `USERNAME` and `ACCESS_TOKEN` (a personal access token), and `GIT_BRANCH` if you don't want the default branch
- Set `GIT_STATUS` to `1` to run `git pull` in `app/` on every start, before your application is built and started
- Point the startup command at the app folder, for example `cd app && cargo run --release`
- Reinstalling the server updates `app/` instead of deleting it. If `app/` contains a different repository or files without Git, the installer leaves it untouched and stops with an error

<br>

## Cronjob

The egg includes a **container-native cron engine** for scheduled tasks, no system cron required.

- Set `CRON_STATUS` to `1`
- Edit `/home/container/crontab` (created on the first start if it doesn't exist)
- Jobs run in the background next to your application, the output goes to `/home/container/logs/cron.log`

```bash
# Every minute
* * * * * echo "$(date): Task executed" >> /home/container/logs/task.log

# Every night at 3 AM: run a maintenance binary of your app
0 3 * * * /home/container/app/target/release/cleanup >> /home/container/logs/cleanup.log 2>&1

# Daily backup of the data folder at 2 AM
0 2 * * * tar -czf /home/container/data-backup-$(date +%Y%m%d).tar.gz -C /home/container data
```

Each time field is either `*` or a single number without leading zeros. Steps (`*/15`), ranges (`1-5`) and lists (`1,15`) are not supported. Always use absolute paths.

<br>

## SSL Certificate with Certbot

If your application serves HTTPS itself, the Certbot module gets a Let's Encrypt certificate through the DNS-01 challenge. No open port 80 is needed. With a Cloudflare Tunnel you don't need this, Cloudflare handles TLS.

1. Set `CERTBOT_STATUS=1`, `CERTBOT_EMAIL` and `CERTBOT_DOMAIN`. Use `CERTBOT_STAGING=1` for the first try
2. Start the server. Certbot shows a TXT record for `_acme-challenge.yourdomain.com`
3. Create that record at your DNS provider and wait a few minutes
4. In the Pterodactyl console type a space and press Enter, twice
5. Once it works with staging, set `CERTBOT_STAGING=0` and `CERTBOT_FORCE_RENEWAL=1` for a real certificate, then set `CERTBOT_FORCE_RENEWAL` back to `0`

The files end up in `/home/container/letsencrypt/config/live/yourdomain.com/`. Your app needs `fullchain.pem` and `privkey.pem`, for example with [axum-server](https://crates.io/crates/axum-server):

```rust
use axum_server::tls_rustls::RustlsConfig;

let config = RustlsConfig::from_pem_file(
    "/home/container/letsencrypt/config/live/yourdomain.com/fullchain.pem",
    "/home/container/letsencrypt/config/live/yourdomain.com/privkey.pem",
)
.await?;
axum_server::bind_rustls(addr, config)
    .serve(app.into_make_service())
    .await?;
```

Certificates are valid for 90 days and are **not** renewed automatically. Renew them before they expire with `CERTBOT_FORCE_RENEWAL=1`.

<br>

## 🚀 Cloudflared Tunnel Tutorial

With **Cloudflared**, you can create a secure tunnel to your server, making it accessible over the internet **without** complicated port forwarding!
[Cloudflared | Create a remotely-managed tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-remote-tunnel/)

### 📌 Requirements
- A [Cloudflare](https://dash.cloudflare.com/) account

---

- 🔹 **Step 1: Log in to Zero Trust and go to Networks > Tunnel**
- 🔹 **Step 2: Select Create a tunnel.**
- 🔹 **Step 3: Choose Cloudflared for the connector type and select Next.**
- 🔹 **Step 4: Enter a name for your tunnel.**
- 🔹 **Step 5: Select Save tunnel.**
- 🔹 **Step 6: Save the token. (The token is very long)**

---

- 🔹 **Step 7: In Pterodactyl, set `CLOUDFLARED_STATUS` to `1`**
- 🔹 **Step 8: Add your token to `CLOUDFLARED_TOKEN`**
- 🔹 **Step 9: In Cloudflare, add public hostname**
- 🔹 **Step 10: Select http and URL "localhost" + your application port (e.g., `localhost:8080`)**
- 🔹 **Step 11: Restart your server**

Your Rust application is now accessible via your Cloudflare domain!

<br>

## Log Cleaner Module

The LogCleaner module automatically cleans up temporary files and old logs on container startup.

### Configuration:

| Variable | Default | Description |
|----------|---------|-------------|
| `LOGCLEANER_STATUS` | `1` | Enable (`1`) or disable (`0`) log cleanup |
| `MAX_SIZE_MB` | `10` | Delete logs larger than this size (MB) |
| `MAX_AGE_DAYS` | `30` | Delete logs older than this many days |

### What Gets Cleaned:

- `/home/container/tmp/*` - All temporary files
- `/home/container/logs/*.log` - Logs exceeding size limit
- `/home/container/logs/*.log` - Logs older than age limit

<br>

## Project Structure

```
/home/container/
├── modules/
│   ├── autoupdate/     # Auto-update module
│   ├── certbot/        # SSL certificate module
│   ├── cloudflared/    # Cloudflare Tunnel module
│   ├── cron/           # Cron engine
│   ├── git/            # Git pull on startup
│   └── logcleaner/     # Log cleanup module
├── logs/               # Application logs
├── tmp/                # Temporary files
├── data/               # Persistent data
├── bin/                # Custom binaries
├── app/                # Your Rust application (if cloned via GIT_REPO)
├── letsencrypt/        # Certificates (created by the certbot module)
├── .cargo/             # Cargo registry and cache
├── crontab             # Your cron jobs (created by the cron module)
├── start-modules.sh    # Module orchestrator
└── VERSION             # Current version file
```

**Note**: Rust toolchain binaries (cargo, rustc, rustup) are installed in `/opt/rust/` and available system-wide.

<br>

## Notes

- Rust toolchain is pre-installed in the container at `/opt/rust/`
- Cargo cache and registry are stored in `/home/container/.cargo/`
- First build may take longer as dependencies are compiled
- Use `RUST_LOG` environment variable to control logging verbosity
- Auto-updates are served from `api.tavuru.de`, which runs the [GitHub Version API](https://github.com/Ym0T/github-version-api). Its source code is public, so you can check exactly what it does
- For production, consider using pre-compiled binaries instead of `cargo run`

<br>

## License

[GPL-3.0 License](https://choosealicense.com/licenses/gpl-3.0/)
