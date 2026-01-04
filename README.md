# Pterodactyl Rust Web Egg

A Pterodactyl Egg for running Rust web applications with Cloudflare Tunnel support, automatic updates, and log management.

<br>

## Table of Contents
- [Features](#features)
- [Docker Images](#docker-images)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Auto-Update System](#auto-update-system)
- [Cloudflared Tunnel Tutorial](#-cloudflared-tunnel-tutorial)
- [Log Cleaner Module](#log-cleaner-module)
- [Project Structure](#project-structure)
- [Notes](#notes)
- [License](#license)

<br>

## Features

- 🦀 **Rust Toolchain**: Pre-installed Rust with cargo, clippy, and rustfmt
- 🔄 **Auto-Update**: Automatically checks for and applies updates via Tavuru API
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
| `GIT_REPO` | `` | Git repository URL to clone (optional) |

### Module Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTOUPDATE_STATUS` | `1` | Enable auto-update checking |
| `AUTOUPDATE_FORCE` | `1` | Apply updates automatically (enabled by default) |
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

- **Automatic Version Checking**: Uses the Tavuru API to check for new releases
- **Smart Differential Updates**: Downloads only changed files, not the entire codebase
- **Selective Updates**: Only updates core system files (modules, scripts)
- **User Data Protection**: Never touches your application code or user data
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
│   ├── cloudflared/    # Cloudflare Tunnel module
│   └── logcleaner/     # Log cleanup module
├── scripts/            # Custom scripts
├── logs/               # Application logs
├── tmp/                # Temporary files
├── data/               # Persistent data
├── bin/                # Custom binaries
├── app/                # Your Rust application (if cloned via GIT_REPO)
├── .cargo/             # Cargo registry and cache
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
- Auto-updates are powered by the [Tavuru API](https://api.tavuru.de) for reliable version management
- For production, consider using pre-compiled binaries instead of `cargo run`

<br>

## License

[GPL-3.0 License](https://choosealicense.com/licenses/gpl-3.0/)
