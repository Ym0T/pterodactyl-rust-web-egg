# Cloudflared Tunnel Module

This module manages a Cloudflare Tunnel at container startup, with configurable settings and robust execution.

## Features

- ✅ Conditional execution based on `CLOUDFLARED_STATUS` (1/0)
- ✅ Reads token from `CLOUDFLARED_TOKEN` environment variable
- ✅ Starts Cloudflared in background, saves PID to `CLOUDFLARED_PID_FILE`
- ✅ Monitors log (`CLOUDFLARED_LOG_FILE`) for success or failure patterns
- ✅ Status updates at configurable intervals (`CLOUDFLARED_STATUS_TIMES`)
- ✅ Failure handling with detailed log output
- ✅ Colorized, structured output
- ✅ Configurable via environment variables

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `CLOUDFLARED_STATUS` | `0` | Enable (`1`) or disable (`0`) Cloudflared startup |
| `CLOUDFLARED_TOKEN` | `""` | Cloudflared auth token |
| `CLOUDFLARED_LOG_FILE` | `/home/container/logs/cloudflared.log` | Path to log file |
| `CLOUDFLARED_PID_FILE` | `/home/container/tmp/cloudflared.pid` | Path to PID file |
| `CLOUDFLARED_MAX_ATTEMPTS` | `130` | Maximum connection wait time (seconds) |
| `CLOUDFLARED_STATUS_TIMES` | `5 10 15 30 60 90 120` | Status update intervals |

## Example Egg JSON Variables

```json
"variables": [
  {
    "name": "Enable Cloudflare Tunnel",
    "env_variable": "CLOUDFLARED_STATUS",
    "default_value": "0",
    "description": "Set to 1 to start Cloudflared tunnel on container startup",
    "user_viewable": true,
    "user_editable": true,
    "rules": "required|boolean",
    "field_type": "text"
  },
  {
    "name": "Cloudflared Token",
    "env_variable": "CLOUDFLARED_TOKEN",
    "default_value": "",
    "description": "The authentication token for Cloudflare Tunnel",
    "user_viewable": true,
    "user_editable": true,
    "rules": "nullable|string",
    "field_type": "text"
  }
]
```

## Script Logic

1. Exit immediately if `CLOUDFLARED_STATUS` is `0` or `false`
2. Validate presence of `CLOUDFLARED_TOKEN`
3. Launch Cloudflared Tunnel in background; log to `CLOUDFLARED_LOG_FILE`
4. Record PID in `CLOUDFLARED_PID_FILE`
5. Loop up to `CLOUDFLARED_MAX_ATTEMPTS` seconds, printing status at intervals
6. On failure to start or missing success message, print last logs and exit 1
7. On success, print confirmation and exit 0

## Example Output

```bash
───────────────────────────────────────────────
[Tunnel] Starting Cloudflared Tunnel
[Tunnel] Waiting for Cloudflared to establish connection...
[Tunnel] Still waiting... (5s)
[Tunnel] Still waiting... (10s)
[Tunnel] Connected after 12s
[Tunnel] Cloudflared is running successfully.
```

## Setup Guide

1. Create a Cloudflare Tunnel in the Zero Trust dashboard
2. Copy the tunnel token (starts with `ey...`)
3. Set `CLOUDFLARED_STATUS=1` in Pterodactyl
4. Paste your token into `CLOUDFLARED_TOKEN`
5. In Cloudflare, configure public hostname pointing to `localhost:PORT`
6. Restart your server

## Troubleshooting

### Tunnel Not Connecting
- Check if token is correct and not expired
- Review logs at `/home/container/logs/cloudflared.log`
- Ensure Cloudflare Tunnel is properly configured in dashboard

### Connection Timeout
- Increase `CLOUDFLARED_MAX_ATTEMPTS` if your network is slow
- Check firewall settings

### Process Dies Immediately
- Token may be invalid or expired
- Check Cloudflare dashboard for tunnel status
