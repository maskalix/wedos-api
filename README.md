# Wedos API (aka WAPI) hook
- Certbot (Let's Encrypt) hook for Wedos API (aka WAPI)
- 🇨🇿 Funguje s Certbotem (testováno) a pravděpodobně i s dalšími generátory SSL certifikátů
- 🇬🇧 Works with Certbot (tested) and probably other SSL certificate generators

## 🇬🇧 Alternative? / 🇨🇿 Alternativa?
https://github.com/alexzorin/certbot-dns-multi

## 🇬🇧 Why to use WAPI? / 🇨🇿 Proč používat WAPI?
- 🇨🇿 automatické ověřování (namísto ručního nastavování záznamů TXT) potřebné pro wildcard SSL certifikáty
- 🇬🇧 automated verification (instead of manual setting TXT records) needed for wildcard SSL certificates

## 🇬🇧 Quick start / 🇨🇿 Rychlý start
- 🇨🇿 ve vybrané složce spusťte:
- 🇬🇧 navigate to desired folder and run:
```bash
git clone https://github.com/maskalix/wedos-api/
```
## 🇬🇧 Usage / 🇨🇿 Použití
```bash
certbot certonly --manual \
  --preferred-challenges dns \
  --manual-auth-hook /path/to/wapi.sh \
  --manual-cleanup-hook /path/to/wapi.sh \
  -d '*.domain.tld' \
  -d domain.tld
```
