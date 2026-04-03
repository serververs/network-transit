#!/usr/bin/env bash
set -euo pipefail

VERSION="v0.2.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[38;2;255;166;50m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "  ${CYAN}${BOLD}→${NC}  $*"; }
success() { echo -e "  ${GREEN}${BOLD}✔${NC}  $*"; }
warn()    { echo -e "  ${YELLOW}${BOLD}!${NC}  $*"; }
die()     { echo -e "\n  ${RED}${BOLD}✘  ERROR:${NC} $*\n"; exit 1; }

print_banner() {
    echo ""
    echo -e "${BOLD}${CYAN}"
    echo "  ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗"
    echo "  ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝"
    echo "  ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝███████╗█████╗  "
    echo "  ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝  "
    echo "  ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║███████║███████╗"
    echo "  ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝"
    echo -e "${NC}"
    echo -e "  ${DIM}Indigenous System for Public Internet  |  Network Transit  |  Built by Hustlers${NC}"
    echo ""
}

SERVER_PUBKEY=""
SERVER_IP=""
CLIENT_IP=""
WG_PORT=""
EXTRA_IP=""
CUSTOM_MODE=false
REMOVE_MODE=false

usage() {
    echo ""
    echo -e "  ${BOLD}Usage:${NC}"
    echo "    sudo bash $0 [options]"
    echo ""
    echo "    --server-pubkey <KEY>"
    echo "    --server-ip     <IP>"
    echo "    --client-ip     <CIDR>"
    echo "    --port          <PORT>"
    echo "    --extra-ip      <IP>"
    echo ""
    echo "    --remove        Uninstall configuration"
    echo "    --version       Show version"
    echo ""
    echo "    --custom        Use custom WireGuard config"
    exit 1
}

# ---------------- ARG PARSE ----------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --server-pubkey) SERVER_PUBKEY="$2"; shift 2 ;;
        --server-ip)     SERVER_IP="$2";     shift 2 ;;
        --client-ip)     CLIENT_IP="$2";     shift 2 ;;
        --port)          WG_PORT="$2";       shift 2 ;;
        --extra-ip)      EXTRA_IP="$2";      shift 2 ;;
        --remove)        REMOVE_MODE=true; shift ;;
        --version)       echo "Serververse Transit ${VERSION}"; exit 0 ;;
        -h|--help)       usage ;;
        --custom) CUSTOM_MODE=true; shift ;;
        *) die "Unknown argument: $1" ;;
    esac
done

[[ "$EUID" -ne 0 ]] && die "Run as root (sudo required)."

print_banner

if $CUSTOM_MODE; then
    info "Custom configuration mode enabled."

    echo "Paste your WireGuard config below. Press Ctrl+D when done:"
    CUSTOM_CONFIG=$(cat)

    WG_DIR="/etc/wireguard"
    CONFIG_FILE="${WG_DIR}/wg0.conf"

    mkdir -p "$WG_DIR"
    chmod 700 "$WG_DIR"

    echo "$CUSTOM_CONFIG" > "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"

    success "Custom configuration saved to ${CONFIG_FILE}"

    read -rp "Start tunnel now? [y/N]: " START_NOW
    if [[ "${START_NOW,,}" == "y" ]]; then
        wg-quick up wg0
        systemctl enable wg-quick@wg0
        success "Tunnel started and enabled."
    fi

    exit 0
fi

WG_DIR="/etc/wireguard"
CONFIG_FILE="${WG_DIR}/wg0.conf"

# ---------------- REMOVE MODE ----------------
if $REMOVE_MODE; then
    warn "Uninstall mode triggered..."
    wg-quick down wg0 2>/dev/null || true
    rm -f "$CONFIG_FILE"
    success "WireGuard stopped (if active) and config removed."
    exit 0
fi

# ---------------- INTERACTIVE FALLBACK ----------------
echo -e "  ${BOLD}Configuration Input${NC}"

[[ -z "$SERVER_PUBKEY" ]] && read -rp "Server Public Key: " SERVER_PUBKEY
[[ -z "$SERVER_IP"     ]] && read -rp "Server IP: " SERVER_IP
[[ -z "$CLIENT_IP"     ]] && read -rp "Client Tunnel CIDR: " CLIENT_IP
[[ -z "$WG_PORT"       ]] && read -rp "WireGuard Port: " WG_PORT
[[ -z "$EXTRA_IP"      ]] && read -rp "Public Routed IP: " EXTRA_IP

# ---------------- VALIDATION ----------------
[[ "$SERVER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid server IP"
[[ "$WG_PORT" =~ ^[0-9]+$ ]] || die "Invalid port"

# ---------------- INSTALL ----------------
info "Installing WireGuard..."

if command -v apt-get &>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq wireguard wireguard-tools
elif command -v yum &>/dev/null; then
    yum install -y -q epel-release
    yum install -y -q wireguard-tools
elif command -v dnf &>/dev/null; then
    dnf install -y -q wireguard-tools
elif command -v pacman &>/dev/null; then
    pacman -S --noconfirm wireguard-tools
else
    die "Unsupported package manager"
fi

success "WireGuard installed."

# ---------------- KEYS ----------------
info "Generating keys..."

mkdir -p "$WG_DIR"
chmod 700 "$WG_DIR"

CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# ---------------- CONFIG ----------------
info "Writing configuration..."

if [[ -f "$CONFIG_FILE" ]]; then
    warn "Existing configuration detected at ${CONFIG_FILE}"
    read -rp "Overwrite? [y/N]: " CONFIRM
    [[ "${CONFIRM,,}" != "y" ]] && die "Aborted by user."
fi

cat > "$CONFIG_FILE" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}
PostUp   = ip addr add ${EXTRA_IP} dev lo
PreDown  = ip addr del ${EXTRA_IP} dev lo

[Peer]
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${SERVER_IP}:${WG_PORT}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

chmod 600 "$CONFIG_FILE"

success "Configuration created."

# ---------------- FINAL OUTPUT ----------------
echo ""
echo -e "${BOLD}Client Public Key:${NC}"
echo -e "${YELLOW}${CLIENT_PUBLIC_KEY}${NC}"
echo ""

# ---------------- OPTIONAL START ----------------
read -rp "Start tunnel now? [y/N]: " START_NOW

if [[ "${START_NOW,,}" == "y" ]]; then
    wg-quick up wg0
    systemctl enable wg-quick@wg0
    success "Tunnel started and enabled."
else
    info "You can start later with: wg-quick up wg0"
fi
