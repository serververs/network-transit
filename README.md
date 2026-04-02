# Serververse™ Network Transit

**Serververse™ Network Transit** is a production-grade IP transit deployment system designed for **developers, homelab operators, and infrastructure engineers**.

It enables secure, high-performance routing of public IPs over encrypted tunnels, with a focus on **automation, reliability, and minimal operational overhead**.

---

## Core Capabilities

* **One-command provisioning** for rapid deployment
* **WireGuard-based encrypted transport**
* **Public IP routing over private infrastructure**
* **Lightweight, dependency-minimal execution**
* **Broad Linux compatibility (VPS, bare metal, containers)**
* **Automation-ready for CI/CD and infra pipelines**

---

## Quick Start

Deploy instantly using:

**Curl**

```bash
bash <(curl -fsSL https://transit.serververs.com/wireguard.sh)
```

**Wget**

```bash
bash <(wget -qO- https://transit.serververs.com/wireguard.sh)
```

---

## Configuration

Run with explicit parameters for production environments:

```bash
bash <(curl -fsSL https://transit.serververs.com/wireguard.sh) \
  --server-pubkey <SERVER_PUBLIC_KEY> \
  --server-ip     <SERVER_ENDPOINT_IP> \
  --client-ip     <CLIENT_TUNNEL_CIDR> \
  --port          <WIREGUARD_PORT> \
  --extra-ip      <ALLOCATED_PUBLIC_IP>
```

---

## Example Deployment

```bash
bash <(curl -fsSL https://transit.serververs.com/wireguard.sh) \
  --server-pubkey W+EwaHbJdR5juu/V4269yRRj7Sfxg2mToTqhDWKr7FA= \
  --server-ip     1.1.1.1 \
  --client-ip     10.1.2.2/30 \
  --port          51822 \
  --extra-ip      1.2.3.4
```

---

## Use Cases

* Exposing **homelab services** with routable public IPs
* Secure tunneling for **game servers (e.g., Minecraft)**
* **Failover and redundancy routing** across regions
* Custom **cloud and hybrid infrastructure networking**
* NAT bypass with **dedicated static IP assignment**
* Advanced routing experiments and lab environments

---

## Operational Notes

* Ensure **out-of-band access (IPMI, VNC, or console)** before deployment
* Incorrect routing rules may temporarily disrupt SSH access
* Intended for users with **working knowledge of Linux networking and routing**
* Current release supports **WireGuard only** (GRE support planned)

---

## Terms & Compliance

By using Serververse™ Network Transit, you agree to the applicable **Terms of Service** and **Privacy Policy**.

---

## Ecosystem

* Network Transit → [https://serververs.com/nt](https://serververs.com/nt)
* Edge & Infrastructure → [https://serververs.com/edge](https://serververs.com/edge)

---

## Contributing

We actively welcome contributions from:

* Infrastructure and network engineers
* Self-hosting and homelab communities
* Open-source contributors

To get started:

* Open an issue for discussion
* Submit a pull request with clear documentation

---

## Version

**v0.1.0 : Initial Public Release**

This version focuses on:
* Core tunnel provisioning
* Stable IP routing workflows
* Minimal, production-usable foundation

Future releases will introduce:
* Multi-IP orchestration
* GRE tunneling support
* CLI tooling and automation layers
* Observability and diagnostics
