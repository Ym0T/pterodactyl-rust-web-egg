# Git Update Module

Runs `git pull` in your application folder on every start, before the application is built and started.

## Features

- Conditional execution based on `GIT_STATUS` (1/0)
- Skips quietly if Git is missing or the folder is not a Git repository
- Updates the remote URL with `USERNAME` and `ACCESS_TOKEN` for private repositories
- Runs right after the auto-update module, so the other modules and your app see the new code
- Colorized, structured output

## Configuration

| Env Variable   | Default                | Description                                    |
|----------------|------------------------|------------------------------------------------|
| `GIT_STATUS`   | `0`                    | Run `git pull` on startup                      |
| `GIT_DIR`      | `/home/container/app`  | Path to the Git repository                     |
| `USERNAME`     | ``                     | Git username for private repositories          |
| `ACCESS_TOKEN` | ``                     | Personal access token for private repositories |

The repository itself is cloned by the installation script from `GIT_REPO` (and `GIT_BRANCH`, if set). This module only keeps it up to date.

## Example Output

```bash
───────────────────────────────────────────────
[Git] Checking & Updating Repository
[Git] No credentials provided; using existing configuration.
[Git] Pulling latest changes…
[Git] Repository updated successfully.
```

## Notes

- `git pull` fails if you changed tracked files in `app/` by hand. The module reports the error and the server keeps starting with the current code
- Build output in `app/target/` is not tracked by Git and stays in place, so `cargo` only rebuilds what changed
