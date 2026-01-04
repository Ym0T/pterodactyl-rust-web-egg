# Auto-Update Module

This module automatically checks for and applies updates to the Pterodactyl Rust Web Egg using the Tavuru API. It runs as the first module during container startup to ensure you're always running the latest version.

## Features

- ✅ **Automatic version checking** using Tavuru API
- ✅ **Smart differential updates** - only downloads changed files
- ✅ **Selective file updates** - only updates allowed directories and files
- ✅ **Version tracking** via local version file
- ✅ **Detailed logging** with colored output
- ✅ **Safe update process** with rollback protection
- ✅ **Configurable update behavior** via environment variables
- ✅ **Network timeout protection** for reliable operations
- ✅ **Cryptographic signature verification** for secure updates

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `AUTOUPDATE_STATUS` | `true` | Enable (`true`/`1`) or disable (`false`/`0`) auto-update |
| `AUTOUPDATE_FORCE` | `false` | Enable automatic downloading and applying of updates |

## Update Scope

The auto-update module only updates specific directories and files to maintain system stability:

### **Allowed Directories:**
- `modules/` - All module scripts and configurations
- `scripts/` - Custom scripts

### **Allowed Files:**
- `start-modules.sh` - Main orchestration script
- `README.md` - Documentation
- `LICENSE` - License file

### **Protected Areas:**
- `app/` - Your Rust application (never touched)
- `src/` - Source code
- `Cargo.toml` - Project configuration
- `logs/` - Log files
- `data/` - User data
- `tmp/` - Temporary files

## How It Works

1. **Version Check**: Reads current version from `/home/container/VERSION`
2. **API Query**: Fetches latest version from `https://api.tavuru.de/version/Ym0T/pterodactyl-rust-web-egg`
3. **Comparison**: Compares current vs latest version
4. **Diff Download**: If update available, downloads differential update package
5. **Signature Verification**: Verifies cryptographic signature (if configured)
6. **Selective Apply**: Applies only changes to allowed directories/files
7. **Version Update**: Updates version file with new version

## API Integration

This module uses the **Tavuru API** for version management:

### Version API
```bash
GET https://api.tavuru.de/version/Ym0T/pterodactyl-rust-web-egg
```

### Diff API
```bash
GET https://api.tavuru.de/diff/Ym0T/pterodactyl-rust-web-egg/{from}/{to}?zip=true
```

## Update Behavior

### Conservative Mode (Default)
- `AUTOUPDATE_STATUS=true`
- `AUTOUPDATE_FORCE=false`
- **Behavior**: Checks for updates and shows availability, but doesn't auto-apply

### Automatic Mode
- `AUTOUPDATE_STATUS=true`
- `AUTOUPDATE_FORCE=true`
- **Behavior**: Automatically downloads and applies updates

### Disabled Mode
- `AUTOUPDATE_STATUS=false`
- **Behavior**: Skips all update operations

## Example Output

```bash
───────────────────────────────────────────────
[AutoUpdate] Checking for Updates
[AutoUpdate] Current version: v1.0.0
[AutoUpdate] Fetching latest version from API...
[AutoUpdate] Latest version: v1.1.0
[AutoUpdate] Update available: v1.0.0 -> v1.1.0
───────────────────────────────────────────────
[AutoUpdate] Applying Update
[AutoUpdate] Downloading update from v1.0.0 to v1.1.0...
[AutoUpdate] Update summary:
  Total changes: 8
  Files added: 2
  Files modified: 5
  Files removed: 1
[AutoUpdate] Downloading update package...
[AutoUpdate] Verifying cryptographic signature...
[AutoUpdate] Hash verified: a1b2c3d4e5f6...
[AutoUpdate] Signature verified - update is authentic
[AutoUpdate] Extracting and applying updates...
[AutoUpdate] Updating directory: modules
[AutoUpdate] Updating file: start-modules.sh
[AutoUpdate] Successfully updated 2 components
[AutoUpdate] Version updated to v1.1.0
[AutoUpdate] Update completed successfully
```

## Security Considerations

- **Limited Scope**: Only updates approved directories and files
- **Version Verification**: Uses official API for version information
- **Signature Verification**: Ed25519 cryptographic signatures ensure authenticity
- **Safe Downloads**: Temporary files are cleaned up after use
- **Network Timeouts**: Prevents hanging on network issues
- **Rollback Safety**: Original files remain untouched during download

## Troubleshooting

### Common Issues

1. **Network connectivity**: Module will fail gracefully if API is unreachable
2. **Version file missing**: Automatically creates with 'unknown' version
3. **Permission issues**: Ensures scripts are executable after update
4. **Download failures**: Cleans up partial downloads automatically

### Manual Version Reset

To reset version tracking:
```bash
echo "unknown" > /home/container/VERSION
```

## Module Dependencies

- **wget/curl**: For API requests and file downloads
- **unzip**: For extracting update packages
- **openssl**: For signature verification (optional)
- **sha256sum**: For hash verification
- Standard Unix utilities (cp, chmod, mkdir, etc.)

All dependencies are included in the base container image.
