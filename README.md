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

### v0.1.2 : Feature Removal

* Removed **custom mode**
* Improved **variables in transit script**
* Removed **uninstall support**

---

### v0.2 : Fresh Update (latest)

* Removed all the old provisionion
* Implemented Token based installed instead of the old
* A dashboard to view your transit ips and get the install key with command
* Changed wireguard configuration on basis of client use cases
* Changed deployment strategy and server side networking for easier management and cleaner routing, as per use case of the customer.
* Fixed a bug where the connections hangs everytime a new keepAlive is sent

---

## ⚠️ Stability Notice

This project is currently in **beta**.  
Breaking changes may occur between minor versions.

---

## Roadmap

* Multi-IP orchestration ✅
* GRE and additional transport support
* CLI tool (`svt`)
* Observability and diagnostics
* Control Panel Introduction ✅

---

# Final Note

This isn’t just a script.

> It’s the foundation for a **programmable network edge layer**.

