# Wedos API (aka WAPI) hook
Certbot (Let's Encrypt) hook for Wedos API (aka WAPI)
Works with Certbot (tested) and probably other SSL certificate generators

## Why to use WAPI? / Proč používat WAPI?
- automated verification (instead of manual setting TXT records) needed for wildcard SSL certificates
- automatické ověřování (namísto ručního nastavování záznamů TXT) potřebné pro wildcard SSL certifikáty

## Quick start / Rychlý start
navigate to desired folder and run: / ve vybrané složce spusťte:
```bash
git clone https://github.com/maskalix/wedos-api/
```

## Usage / Použití
```bash
certbot certonly --manual \
  --preferred-challenges dns \
  --manual-auth-hook /path/to/wapi.sh \
  --manual-cleanup-hook /path/to/wapi.sh \
  -d '*.domain.tld' \
  -d domain.tld
```
