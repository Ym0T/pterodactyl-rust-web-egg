# LogCleaner Module

This module runs at container startup to clean up temporary and log files based on configurable thresholds.

## Features

- ✅ Conditional execution based on `LOGCLEANER_STATUS` (1 to enable)
- ✅ Removes all files in the temporary directory (`/home/container/tmp`)
- ✅ Deletes log files in `/home/container/logs` that are:
  - larger than `MAX_SIZE_MB` (default: 10 MB)
  - older than `MAX_AGE_DAYS` (default: 30 days)
- ✅ Supports dry-run via `DRY_RUN` (lists files without deleting)
- ✅ Colorized, structured output for easy reading
- ✅ Robust error handling with `set -euo pipefail` and trap on error

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `LOGCLEANER_STATUS` | `1` | Enable (`true`/`1`) or disable (`false`/`0`) module |
| `LOG_DIR` | `/home/container/logs` | Directory where log files are stored |
| `TMP_DIR` | `/home/container/tmp` | Directory for temporary files |
| `MAX_SIZE_MB` | `10` | Remove log files larger than this (in MB) |
| `MAX_AGE_DAYS` | `30` | Remove log files older than this (in days) |
| `DRY_RUN` | `false` | When `true`, only shows what would be deleted |

## Example Egg JSON Variables

```json
"variables": [
  {
    "name": "Enable LogCleaner",
    "env_variable": "LOGCLEANER_STATUS",
    "default_value": "1",
    "description": "Enable or disable the LogCleaner module",
    "user_viewable": true,
    "user_editable": true,
    "rules": "required|boolean",
    "field_type": "text"
  },
  {
    "name": "Max Log File Size (MB)",
    "env_variable": "MAX_SIZE_MB",
    "default_value": "10",
    "description": "Maximum log file size before deletion",
    "user_viewable": true,
    "user_editable": true,
    "rules": "required|integer",
    "field_type": "text"
  },
  {
    "name": "Max Log Age (days)",
    "env_variable": "MAX_AGE_DAYS",
    "default_value": "30",
    "description": "Maximum log file age before deletion",
    "user_viewable": true,
    "user_editable": true,
    "rules": "required|integer",
    "field_type": "text"
  }
]
```

## Example Output

```bash
───────────────────────────────────────────────
[Logcleaner] Starting log cleanup
[Logcleaner] Removing temporary files and directories
[Logcleaner] Deleting: /home/container/tmp/update.zip
[Logcleaner] Deleting: /home/container/tmp/cache_12345
[Logcleaner] Cleaning logs larger than 10MB
[Logcleaner] No logs exceed 10MB.
[Logcleaner] Cleaning logs older than 30 days
[Logcleaner] Deleting: /home/container/logs/old-app.log
[Logcleaner] Log cleanup complete.
```

## Dry Run Mode

To test what would be deleted without actually removing files:

```bash
export DRY_RUN=true
```

Output will show:
```bash
[Logcleaner][DRY-RUN] Would delete: /home/container/tmp/cache_12345
[Logcleaner][DRY-RUN] Would delete: /home/container/logs/old-app.log
```

## Script Details

- Uses `shopt -s nullglob` to handle empty directories gracefully
- Gathers files via `find` and `mapfile`, then loops through arrays to delete
- `delete_path` helper respects `DRY_RUN` mode
- Each major section prints a header for clarity
- Errors trap with line number for quick debugging

## What Gets Cleaned

### Temporary Files (`/home/container/tmp/`)
- All files and directories are removed
- Cleaned on every startup

### Log Files (`/home/container/logs/`)
- Files matching `*.log` pattern
- Only removed if exceeding size OR age threshold
- Your application logs are safe unless they match the criteria

## Best Practices

1. **Set appropriate thresholds**: Adjust `MAX_SIZE_MB` and `MAX_AGE_DAYS` based on your needs
2. **Use dry-run first**: Test with `DRY_RUN=true` before enabling
3. **Monitor disk usage**: Large logs can fill up container storage
4. **Rotate logs in your app**: Configure your Rust application to rotate logs properly
