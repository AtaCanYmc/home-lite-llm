# Port Forwarding Integration

Exposes LiteLLM directly to the internet via your modem's **port forwarding** feature. Requires a static IP address or a DDNS service.

> ⚠️ **Security Warning:** This method exposes your server directly to the internet. For production use, prefer **Cloudflare Tunnel** or **Tailscale**. Use port forwarding only for testing or on trusted networks.

---

## Requirements

| Requirement | Description |
|:---|:---|
| Static local IP | Your server's local IP must not change (configure via modem DHCP reservation or Linux netplan) |
| Static public IP or DDNS | Use a free DDNS service if your ISP does not provide a static IP |
| Modem admin access | Ability to add a port forwarding rule through the modem interface |

---

## Step 1 — DDNS Setup (If You Don't Have a Static IP)

You can use **Duck DNS** (free) for dynamic IP addresses.

```bash
chmod +x tunnels/port-forwarding/setup-ddns.sh

DUCKDNS_TOKEN=<your_token> \
DUCKDNS_DOMAIN=<your_subdomain> \
  ./tunnels/port-forwarding/setup-ddns.sh
```

### How to Get a Duck DNS Token and Domain

1. Go to [duckdns.org](https://www.duckdns.org) → sign in with GitHub / Google
2. Choose a subdomain under **Domains** (e.g. `my-litellm`)
3. Copy the **token** value shown at the top of the page
4. Run the script

The script automatically:
- Sends the initial IP update to Duck DNS
- Adds a **cron job** that updates the record every 5 minutes
- Creates a log file: `~/.duckdns-update.log`

### Alternative DDNS Services

| Service | Free Plan | Custom Domain |
|:---|:---:|:---:|
| [Duck DNS](https://www.duckdns.org) | ✅ 5 subdomains | ❌ |
| [No-IP](https://www.noip.com) | ✅ 1 subdomain | ❌ |
| [Dynu](https://www.dynu.com) | ✅ 4 subdomains | ✅ |
| [Cloudflare DNS](https://dash.cloudflare.com) | ✅ (with your own domain) | ✅ |

---

## Step 2 — Assign a Static Local IP to the Server

Port forwarding requires the server's local IP to remain constant.

### Method A: MAC → IP Reservation in the Modem (Recommended)

1. Open your modem interface (usually `http://192.168.1.1`)
2. Find **DHCP → Static Lease / Address Reservation**
3. Enter the server's MAC address and the IP you want to assign (e.g. `192.168.1.100`)

To find the server's MAC address:
```bash
ip link show | grep "link/ether"
```

### Method B: Static IP on Linux (Netplan)

```yaml
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

```bash
sudo netplan apply
```

---

## Step 3 — Add a Port Forwarding Rule in the Modem

### General Steps

1. Open the modem interface (usually `http://192.168.1.1` or `http://192.168.0.1`)
2. Find **Port Forwarding** / **Virtual Server** / **NAT**
3. Add a new rule:

```
Protocol      : TCP
External Port : 4000
Internal IP   : 192.168.1.100  (your server's local IP)
Internal Port : 4000
```

### Common Modem Brands

| Brand | Menu Path |
|:---|:---|
| TP-Link | Advanced → NAT Forwarding → Virtual Servers |
| ASUS | WAN → Virtual Server / Port Forwarding |
| Netgear | Advanced → Dynamic DNS → Port Forwarding/Port Triggering |

---

## Step 4 — Verify

```bash
# Find your public IP
curl https://api.ipify.org

# Test from another network or via mobile data
curl http://my-litellm.duckdns.org:4000/health

# API test
curl http://my-litellm.duckdns.org:4000/v1/chat/completions \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gemini-2.0-flash", "messages": [{"role": "user", "content": "Test!"}]}'
```

### Check Whether the Port Is Open

```bash
# From another machine or via an online tool:
# https://www.yougetsignal.com/tools/open-ports/
nc -zv my-litellm.duckdns.org 4000
```

---

## 🔒 Security Measures

If you use port forwarding, make sure to take the following steps:

### LiteLLM Master Key
Ensure you have a strong `MASTER_KEY` in your `.env` file:
```bash
# Generate a strong key
openssl rand -hex 24
```

### Firewall (UFW)
```bash
# Allow only the LiteLLM port
sudo ufw allow 4000/tcp
sudo ufw enable

# Restrict to specific IPs:
sudo ufw allow from 1.2.3.4 to any port 4000
```

### Fail2Ban (Brute-force Protection)
```bash
sudo apt install fail2ban
# Custom rules can be added for LiteLLM logs
```

### HTTPS via Reverse Proxy (Recommended)

Set up Nginx + Let's Encrypt instead of serving plain HTTP:

```bash
sudo apt install nginx certbot python3-certbot-nginx
sudo certbot --nginx -d my-litellm.duckdns.org
```

Nginx config (`/etc/nginx/sites-available/litellm`):
```nginx
server {
    listen 443 ssl;
    server_name my-litellm.duckdns.org;

    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Monitor DDNS Update Status

```bash
# View update logs
tail -f ~/.duckdns-update.log

# Trigger a manual update
~/.duckdns-update.sh

# View the cron job
crontab -l | grep duckdns

# Remove the cron job
crontab -l | grep -v 'duckdns-update' | crontab -
```
