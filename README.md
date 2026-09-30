# Serververse™ Network Transit

> Routable public IPs for any Linux machine — even behind CGNAT — provisioned with a single token.

![Status](https://img.shields.io/badge/status-beta-orange) ![Version](https://img.shields.io/badge/version-v0.3-blue) ![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)

**Serververse™ Network Transit** is an IP transit service for **developers, homelab operators, and infrastructure engineers**. It tunnels real, routable public IPs from the Serververse network to your server over an encrypted WireGuard link, so you can host services without port forwarding, NAT, or a static IP from your ISP.

---

## Table of Contents

- [How It Works](#how-it-works)
- [Features](#features)
- [Use Cases](#use-cases)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Before You Deploy](#before-you-deploy)
- [Changelog](#changelog)
- [Roadmap](#roadmap)
- [Serververse Ecosystem](#serververse-ecosystem)
- [Support](#support)
- [License](#license)

---

## How It Works

```
 Internet ──► Serververse Edge ══ WireGuard tunnel ══► Your server
               (public IP lives here)                 (IP routed to you)
```

1. You sign in to the Serververse Labs dashboard and get a public IP (or subnet) assigned.
2. The dashboard gives you a one-time **install token** and command.
3. Running the command on your machine sets up the tunnel and routes the IP to your server.
4. Traffic to that IP now reaches your machine directly — no port forwarding required.

---

## Features

| | |
|---|---|
| **Token-based install** | One command, one token — no manual WireGuard config |
| **`sv-transit` CLI** | Install the tunnel and check its status from the terminal |
| **Web dashboard** | View your transit IPs, grab install keys, and monitor bandwidth |
| **Multi-IP & subnets** | Single IPs or routed subnets, including Proxmox setups |
| **Email alerts** | Get notified about important events on your account |
| **Audit logging** | Every account action is recorded |
| **Google sign-in** | Register and log in with your Google account |
| **Broad compatibility** | VPS, bare metal, and containers on most Linux distributions |

---

## Use Cases

- **Homelabs** — expose self-hosted services on a real public IP
- **Game servers** — host Minecraft and other games behind CGNAT
- **Proxmox** — route a subnet to your hypervisor and hand IPs to VMs
- **Failover & redundancy** — keep a stable IP across regions or hardware
- **Hybrid cloud** — connect on-prem machines to cloud networks with static IPs
- **Network labs** — experiment with real routing on real address space

---

## Requirements

- A Linux system (VPS, bare metal, or container with network privileges)
- Root / `sudo` access
- Outbound internet connectivity (UDP must not be blocked)
- A Serververse Labs account
- **Proxmox only:** a subnet of **/28 or larger**

---

## Quick Start

1. **Sign in** to the dashboard at [serververs.com/nt](https://serververs.com/nt) (Google sign-in supported).
2. **Get your install command** — open your transit IP and copy the command with your install token.
3. **Run it** on your server as root:

   ```bash
   # Paste the exact command from your dashboard
   <install command with your token>
   ```

4. **Check the tunnel** with the CLI:

   ```bash
   sv-transit status
   ```

Your public IP should now be reachable. Bandwidth stats appear in the dashboard shortly after.

---

## Before You Deploy

> [!WARNING]
> Changing routes on a remote machine can cut off your SSH session.

- Make sure you have **out-of-band access** (IPMI, VNC, or a provider console) before installing.
- This service assumes you're comfortable with **basic Linux networking** (interfaces, routes, firewalls).
- Open the ports your services need in your firewall — the public IP is fully exposed to the internet.
- Treat your install token like a password. Don't commit it or share it publicly.

---

## Changelog

### v0.3 — The New Phase *(current)*
- Redesigned dashboard interface
- Google sign-in for Labs accounts
- Email alerts for users
- Bandwidth statistics in the dashboard
- Proxmox support (subnets /28 or larger)
- Account audit logging
- New `sv-transit` CLI to install and check transit status

### v0.2 — Fresh Update
- Replaced the old provisioning flow with **token-based installs**
- Dashboard to view transit IPs and get install commands
- WireGuard configuration now tailored to each customer's use case
- Reworked server-side networking and deployment for cleaner routing and easier management
- Fixed connections hanging whenever a keepalive was sent

### v0.1.2 — Simplification
- Removed custom mode
- Removed uninstall support
- Cleaned up variables in the transit script

### v0.1.1 — Usability & Control
- Interactive configuration mode
- Basic input validation
- Optional tunnel auto-start
- Custom configuration mode (`--custom`)
- Uninstall support (`--remove`)
- Version flag (`--version`)

### v0.1.0 — Initial Public Release
- Core transit provisioning
- Stable IP routing workflows

---

## Roadmap

- [x] Multi-IP orchestration
- [x] `sv-transit` CLI
- [x] Control panel / dashboard
- [ ] GRE and additional transport protocols
- [ ] Observability and diagnostics tooling

---

> **Beta notice:** Network Transit is in active development. Breaking changes may occur between minor versions.

---

## Serververse Ecosystem

- **Network Transit** — [serververs.com/nt](https://serververs.com/nt)
- **Edge Platform** — [serververs.com/edge](https://serververs.com/edge)

---

## Support

- Email: [info@serververs.com](mailto:info@serververs.com)
- Bugs & feature requests: open an issue in this repository

---

## License

Proprietary software © Serververse™, a subsidiary of AR Solution. All rights reserved.
Unauthorized use, modification, or distribution is prohibited.

By using Serververse™ Network Transit you agree to the Serververse **Terms of Service** and **Privacy Policy**.

---

<p align="center"><i>Not just a tunnel — the foundation for a programmable network edge.</i></p>