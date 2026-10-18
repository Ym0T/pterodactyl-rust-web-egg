# Certbot SSL Certificate Module

Gets a Let's Encrypt certificate through Certbot's DNS-01 challenge on startup. You confirm the DNS record in the Pterodactyl console, no open port 80 or 443 is needed.

## Features

- Conditional execution based on `CERTBOT_STATUS` (1/0)
- DNS-01 challenge with step-by-step instructions in the console
- Skips the request if the current certificate is valid for more than 30 days
- Staging mode for testing without hitting Let's Encrypt's rate limits
- Force renewal option

## Configuration

| Environment Variable    | Default                                   | Description                                   |
|-------------------------|-------------------------------------------|-----------------------------------------------|
| `CERTBOT_STATUS`        | `0`                                       | Enable (`1`) or disable (`0`) the module      |
| `CERTBOT_EMAIL`         | ``                                        | Email for Let's Encrypt notifications (required) |
| `CERTBOT_DOMAIN`        | ``                                        | Domain for the certificate (required)         |
| `CERTBOT_STAGING`       | `0`                                       | Use the staging server (untrusted test certificates) |
| `CERTBOT_FORCE_RENEWAL` | `0`                                       | Request a new certificate even if the current one is valid |
| `CERTBOT_LOG_FILE`      | `/home/container/logs/certbot.log`        | Log file                                      |
| `CERTBOT_CERT_PATH`     | `/home/container/letsencrypt/config/live` | Where the certificates end up                 |

## Getting a Certificate

1. Set `CERTBOT_STATUS=1`, `CERTBOT_EMAIL`, `CERTBOT_DOMAIN` and `CERTBOT_STAGING=1`
2. Start the server. Certbot shows a TXT record for `_acme-challenge.yourdomain.com`
3. Create the record at your DNS provider and wait 2-5 minutes. You can check it with `nslookup -type=TXT _acme-challenge.yourdomain.com`
4. In the Pterodactyl console type a space and press Enter. You need to do this twice
5. If the staging certificate works, set `CERTBOT_STAGING=0` and `CERTBOT_FORCE_RENEWAL=1` and repeat for a real certificate
6. Set `CERTBOT_FORCE_RENEWAL` back to `0`

## Certificate Files

```
/home/container/letsencrypt/config/live/yourdomain.com/
├── fullchain.pem   # certificate + chain, use this one
├── privkey.pem     # private key
├── cert.pem        # certificate only
└── chain.pem       # chain only
```

Your Rust application loads `fullchain.pem` and `privkey.pem`, for example with `axum_server::tls_rustls::RustlsConfig::from_pem_file`.

## Renewal

Certificates are valid for 90 days. Manual DNS validation can't be renewed automatically, so set `CERTBOT_FORCE_RENEWAL=1` before the expiry date, restart, create the new TXT record and set it back to `0` afterwards. On every start the module prints the expiry date.

## Troubleshooting

- **Browser doesn't trust the certificate**: it is probably a staging certificate, see step 5
- **DNS validation fails**: check the record name and value and wait longer, propagation can take up to 10 minutes
- **"Certificate already exists"**: the current one is still valid, use `CERTBOT_FORCE_RENEWAL=1` to replace it
- **Rate limits**: Let's Encrypt allows 5 failed validations per hour, test with staging first
