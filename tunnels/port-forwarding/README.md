[← Back to Remote Access Overview](../README.md) | [← Back to Root Repository](../../README.md)

# Port Forwarding Integration

Exposes the LiteLLM proxy directly to the public internet using router port forwarding and dynamic DNS (DDNS).

> Security Notice: Exposing HTTP services directly to the public internet increases attack surface. For production environments, prefer Cloudflare Tunnel or Tailscale. If using port forwarding, place a reverse proxy (e.g. Nginx, Caddy, or Traefik) in front with TLS termination and rate limiting.

---

## Technical Prerequisites

| Requirement | Specification |
| :--- | :--- |
| **Static Host IP** | Static DHCP reservation configured via router MAC binding or static network configuration |
| **Public IP or DDNS** | Static public IPv4 address or an active Dynamic DNS updater client |
| **Router Admin Access** | Capability to define TCP port forwarding (NAT virtual server) rules |

---

## Step 1: Dynamic DNS Configuration

If your ISP assigns dynamic public IP addresses, configure a DDNS updater client using Duck DNS:

```bash
chmod +x tunnels/port-forwarding/setup-ddns.sh

DUCKDNS_TOKEN=<your_token> \
DUCKDNS_DOMAIN=<your_subdomain> \
  ./tunnels/port-forwarding/setup-ddns.sh
```

### Obtaining Duck DNS Credentials
1. Authenticate at [duckdns.org](https://www.duckdns.org).
2. Create a target subdomain (e.g. `my-litellm`).
3. Copy the account token displayed on the dashboard.
4. Execute the setup script.

The script performs the initial DNS update, creates a local cron job scheduled every 5 minutes, and logs activity to `~/.duckdns-update.log`.

---

## Step 2: Static Local IP Assignment

Assign a permanent IPv4 address to the host server.

### Option A: Router DHCP Static Lease (Recommended)
1. Open your router management interface (e.g. `http://192.168.1.1`).
2. Navigate to **DHCP Server** -> **Static Leases** / **Address Reservation**.
3. Bind the server MAC address to a fixed local IP (e.g. `192.168.1.100`).

Identify the server MAC address:
```bash
ip link show | grep "link/ether"
```

### Option B: Linux Netplan Static Configuration
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

Apply network changes:
```bash
sudo netplan apply
```

---

## Step 3: Configure Router NAT Port Forwarding

Define an inbound forwarding rule in your router settings:

```text
Service Name  : LiteLLM-Proxy
Protocol      : TCP
External Port : 4000 (or custom external port, e.g. 8443)
Internal IP   : 192.168.1.100
Internal Port : 4000
```

---

## Step 4: Verification

Test external accessibility from a network outside your local LAN:

```bash
curl https://my-litellm.duckdns.org:4000/health/readiness
```
