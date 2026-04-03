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
bash <(curl -fsSL https://transit.serververs.com/transit.sh)
```

### Wget

```bash
bash <(wget -qO- https://transit.serververs.com/transit.sh)
```

---

## Configuration

Run with explicit parameters for production environments:

```bash
bash <(curl -fsSL https://transit.serververs.com/transit.sh) \
  --server-pubkey <SERVER_PUBLIC_KEY> \
  --server-ip     <SERVER_ENDPOINT_IP> \
  --client-ip     <CLIENT_TUNNEL_CIDR> \
  --port          <PORT> \
  --extra-ip      <ALLOCATED_PUBLIC_IP>
```

---

## Example Deployment

```bash
bash <(curl -fsSL https://transit.serververs.com/transit.sh) \
  --server-pubkey W+EwaHbJdR5juu/V4269yRRj7Sfxg2mToTqhDWKr7FA= \
  --server-ip     1.1.1.1 \
  --client-ip     10.1.2.2/30 \
  --port          51822 \
  --extra-ip      1.2.3.4
```

---

## Installation Modes

### 1. Interactive Mode

If no parameters are provided, the installer will prompt for required values step-by-step.

### 2. CLI Mode

All parameters can be passed directly for automation and scripting.

### 3. Custom Mode

Use your own configuration:

```bash
bash <(curl -fsSL https://transit.serververs.com/transit.sh) --custom
```

This allows full manual control over the generated configuration.

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
bash <(curl -fsSL https://transit.serververs.com/transit.sh) --remove
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
