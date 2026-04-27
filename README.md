# Serververse™ Network Transit

**Serververse™ Network Transit** is a production-grade IP transit deployment system designed for **developers, homelab operators, and infrastructure engineers**.

It enables secure, high-performance routing of public IPs over private infrastructure with a focus on **automation, reliability, and minimal operational overhead**.

---

## Overview

Serververse™ Network Transit provides a streamlined way to attach **routable public IPs** to any Linux-based system through an automated provisioning workflow.

Built for flexibility, it is designed to evolve across multiple transport mechanisms while maintaining a consistent deployment experience.

---

## Core Capabilities

* **One-command provisioning** for rapid deployment
* **Protocol-agnostic architecture** (designed for extensibility)
* **Public IP routing over private infrastructure**
* **Lightweight and dependency-minimal execution**
* **Broad Linux compatibility (VPS, bare metal, containers)**
* **Automation-ready for CI/CD and infrastructure pipelines**

---

## Quick Start

Deploy instantly using:

### Curl

```bash
bash <(curl -fsSL https://transit.serververs.com/latest/transit.sh)
```

### Wget

```bash
bash <(wget -qO- https://transit.serververs.com/latest/transit.sh)
```

---

## Configuration

Run with explicit parameters for production environments:

```bash
bash <(curl -fsSL https://transit.serververs.com/latest/transit.sh) \
  --UPSTREAM_KEY    <SERVER_PUBLIC_KEY> \
  --upstream-ip     <SERVER_ENDPOINT_IP> \
  --NODE_ADDR       <CLIENT_TUNNEL_CIDR> \
  --UPSTREAM_PO     <PORT> \
  --node-key        <CLIENT_KEY> \
  --routed-ip       <ALLOCATED_PUBLIC_IP>
```

---

## Example Deployment

```bash
bash <(curl -fsSL https://transit.serververs.com/latest/transit.sh) \
  --UPSTREAM_KEY    W+EwaHbJdR5juu/V4269yRRj7Sfxg2mToTqhDWKr7FA= \
  --upstream-ip     1.1.1.1 \
  --NODE_ADDR       10.1.2.2/30 \
  --UPSTREAM_PO     51822 \
  --node-key        WSMKDlgmsd@KkfmjGWQ4115ma/agkaaa1 \
  --routed-ip       1.2.3.4
```

---

## Use Cases

* Exposing **homelab services** with public IPs
* Secure connectivity for **game servers (e.g., Minecraft)**
* **Failover and redundancy routing** across regions
* Custom **cloud and hybrid infrastructure networking**
* NAT bypass with **dedicated static IP assignment**
* Advanced routing experiments and lab environments

---

## Operational Notes

* Ensure **out-of-band access (IPMI, VNC, or console)** before deployment
* Incorrect routing may temporarily disrupt SSH access
* Intended for users familiar with **Linux networking concepts**
* Underlying transport mechanisms may evolve across versions

---

## Uninstall / Cleanup

To remove configuration:

```bash
bash <(curl -fsSL https://transit.serververs.com/latest/uninstall.sh) --remove
```

---

## Terms & Compliance

By using Serververse™ Network Transit, you agree to the applicable:

* Terms of Service
* Privacy Policy

---

## Serververse Ecosystem

* Network Transit → [serververs.com/nt](https://serververs.com/nt)
* Edge Platform → [serververs.com/edge](https://serververs.com/edge)

---

## Contributing

We welcome contributions from:

* Infrastructure and network engineers
* Self-hosting and homelab communities
* Open-source contributors

### Getting Started

* Open an issue for discussion
* Submit a pull request with clear documentation

## License

This project is proprietary software owned by Serververse™.

Unauthorized use, modification, or distribution is strictly prohibited.

---

## Version

### v0.1.0 : Initial Public Release

* Core transit provisioning
* Stable IP routing workflows
* Minimal production-ready foundation

---

### v0.1.1 : Usability & Control Update

* Added **interactive configuration mode**
* Introduced **basic input validation**
* Added **optional tunnel auto-start**
* Introduced **custom configuration mode (`--custom`)**
* Added **uninstall support (`--remove`)**
* Added **version flag (`--version`)**

---

### v0.1.2 : Feature Removal (latest)

* Removed **custom mode**
* Improved **variables in transit script**

---
## ⚠️ Stability Notice

This project is currently in **beta**.  
Breaking changes may occur between minor versions.

---

## Roadmap

* Multi-IP & Subnet Level orchestration
* GRE and additional transport support
* CLI tool (`svt`)
* Observability and diagnostics
* Control Panel Introduction

---

# Final Note

This isn’t just a script.

> It’s the foundation for a **programmable network edge layer**.

