# Cron Module

Runs scheduled tasks with a small cron engine written in Bash, so no system cron is needed inside the container.

## Features

- Conditional execution based on `CRON_STATUS` (1/0)
- Creates a commented crontab template on the first start
- Checks every line on startup and stops with an error if one is broken
- Runs in the background next to your application, PID in `tmp/cron.pid`
- Logs every executed job to `logs/cron.log`
- Commands run through `bash -c`, so `$(date)`, pipes and redirects work

## Configuration

| Environment Variable | Default                         | Description                     |
|----------------------|---------------------------------|---------------------------------|
| `CRON_STATUS`        | `0`                             | Enable (`1`) or disable (`0`)   |
| `CRON_CONFIG_FILE`   | `/home/container/crontab`       | Path to the crontab file        |
| `CRON_LOG_FILE`      | `/home/container/logs/cron.log` | Log file of the cron engine     |
| `CRON_PID_FILE`      | `/home/container/tmp/cron.pid`  | PID file of the cron engine     |

## Crontab Format

```
minute hour day month weekday command
```

Each time field is either `*` or a single number without leading zeros (minute `0-59`, hour `0-23`, day `1-31`, month `1-12`, weekday `0-6` with `0` = Sunday). Steps (`*/15`), ranges (`1-5`) and lists (`1,15`) are not supported.

## Examples

```bash
# Every minute
* * * * * echo "$(date): Task executed" >> /home/container/logs/task.log

# Every hour at minute 0
0 * * * * /home/container/app/target/release/sync >> /home/container/logs/sync.log 2>&1

# Every night at 3 AM
0 3 * * * /home/container/app/target/release/cleanup >> /home/container/logs/cleanup.log 2>&1

# Every Sunday at midnight: delete logs older than 7 days
0 0 * * 0 find /home/container/logs -name "*.log" -mtime +7 -delete
```

Always use absolute paths and redirect the output of your jobs to a log file.

## Troubleshooting

```bash
# What the engine did
tail -f /home/container/logs/cron.log

# Is it running?
ps aux | grep cron-engine
```

- **Job doesn't run**: check `logs/cron.log` and whether the time fields only use `*` and single numbers
- **Command not found**: use absolute paths, the job doesn't run inside `app/`
- **Changes to the crontab**: the engine reads the file every minute, a restart is not needed

## Files

```
modules/cron/
├── start.sh          # Validates the crontab and starts the engine
├── cron-engine.sh    # The cron engine itself
└── README.md
```
