## Serververse™ Network Transit

A minimal, production-oriented **IP Transit System** built for developers, homelabs, and infrastructure engineers.

---

### Features

* One-command deployment
* WireGuard-based secure tunneling
* Public IP routing support
* Lightweight & dependency-minimal
* Works on most Linux distributions
* Designed for automation pipelines

---

### Quick Start

Curl:
```bash
bash <(curl -fsSL https://transit.serververs.com/wireguard.sh)
```
or
Wget:
```bash
bash <(wget -qO- https://transit.serververs.com/wireguard.sh)
```

---

### Usage

```bash
bash <(curl -fsSL https://transit.serververs.com/wireguard.sh) \
  --server-pubkey <KEY> \
  --server-ip     <IP> \
  --client-ip     <CIDR> \
  --port          <PORT> \
  --extra-ip      <PUBLIC_IP>
```

---

### Example

```bash
bash <(curl -fsSL https://transit.serververs.com/wireguard.sh) \
  --server-pubkey W+EwaHbJdR5juu/V4269yRRj7Sfxg2mToTqhDWKr7FA= \
  --server-ip     1.1.1.1 \
  --client-ip     10.1.2.2/30 \
  --port          51822 \
  --extra-ip      1.2.3.4
```

---

### 🧠 Use Cases

* Homelab public exposure via routed IP
* Game server tunneling (Minecraft, etc.)
* Failover networking setups
* Custom cloud infrastructure routing
* ISP bypass / advanced routing labs
* Static IP Alternative for NAT Users

---

### ⚠️ Notes

* Always ensure **out-of-band access (IPMI/VNC)** before running
* Misconfiguration may break SSH connectivity
* Designed for users familiar with Linux networking
* Currently only for Wireguard, GRE Support will be added soon.

---

### 🔐 Terms

By using this script, you agree to Serververse™ Terms of Service and Privacy Policy.

---

### 🌐 Ecosystem

* Network Transit → [serververs.com/nt](https://serververs.com/nt)
* Core Platform → [serververs.com/edge](https://serververs.com/edge)

---

### 🤝 Contributing

We welcome contributors from:

* Self-hosting community
* Homelab builders
* Network engineers

Open a PR or issue to get started.
