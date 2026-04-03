#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
    echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

SERVER_PUBKEY=""
SERVER_IP=""
CLIENT_IP=""
WG_PORT=""
EXTRA_IP=""

usage() {
    echo ""
    echo -e "  ${BOLD}Usage:${NC}"
    echo "    sudo bash $0 \\"
    echo "      --server-pubkey <SERVER_PUBLIC_KEY> \\"
    echo "      --server-ip     <SERVER_PUBLIC_IP>  \\"
    echo "      --client-ip     <CLIENT_WG_IP/CIDR> \\"
    echo "      --port          <WG_PORT>            \\"
    echo "      --extra-ip      <IP>                 "
    echo ""
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --server-pubkey) SERVER_PUBKEY="$2"; shift 2 ;;
        --server-ip)     SERVER_IP="$2";     shift 2 ;;
        --client-ip)     CLIENT_IP="$2";     shift 2 ;;
        --port)          WG_PORT="$2";       shift 2 ;;
        --extra-ip)      EXTRA_IP="$2";      shift 2 ;;
        -h|--help)       usage ;;
        *) die "Unknown argument: $1"; usage ;;
    esac
done

[[ -z "$SERVER_PUBKEY" ]] && die "--server-pubkey is required."
[[ -z "$SERVER_IP"     ]] && die "--server-ip is required."
[[ -z "$CLIENT_IP"     ]] && die "--client-ip is required."
[[ -z "$WG_PORT"       ]] && die "--port is required."
[[ -z "$EXTRA_IP"      ]] && die "--extra-ip is required."
[[ "$EUID" -ne 0 ]]       && die "This script must be run as root (use sudo)."

print_banner

echo -e "  ${BOLD}Welcome to Serververse™ Network Transit${NC}"
echo ""
echo -e "  This installer will configure a Tunnel to the Serververse™"
echo -e "  Transit Network on this Machine."
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Terms of Service & Acceptable Use Policy${NC}"
echo ""
echo -e "  By continuing you confirm that:"
echo -e "    ${DIM}1.${NC}  You are an authorised Serververse™ User."
echo -e "    ${DIM}2.${NC}  You will not use this tunnel for any unlawful, abusive, or"
echo -e "         harmful activity."
echo -e "    ${DIM}3.${NC}  You accept Serververse's full Terms of Service and Privacy Policy,"
echo -e "         available at ${CYAN}https://serververs.com/tos${NC} ${CYAN}https://serververs.com/privacy${NC}"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -rp "  Do you agree to the Terms of Service and Acceptable Use Policy? [yes/no]: " TOS_ANSWER
echo ""

case "${TOS_ANSWER,,}" in
    yes|y) success "Terms accepted. Proceeding with setup." ;;
    *)
        warn "You must accept the Terms of Service and Privacy Policy to continue."
        echo -e "\n  Setup aborted. No changes were made to this system.\n"
        exit 1
        ;;
esac

echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Configuring network transit…${NC}"
echo ""

info "Detecting package manager…"

if command -v apt-get &>/dev/null; then
    PKG_MGR="apt-get"
    info "Updating package lists…"
    apt-get update -qq
    info "Installing WireGuard…"
    apt-get install -y -qq wireguard wireguard-tools
elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
    info "Installing EPEL & WireGuard (yum)…"
    yum install -y -q epel-release
    yum install -y -q wireguard-tools
elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
    info "Installing WireGuard (dnf)…"
    dnf install -y -q wireguard-tools
elif command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
    info "Installing WireGuard (pacman)…"
    pacman -S --noconfirm --quiet wireguard-tools
else
    die "No supported package manager found (apt / yum / dnf / pacman)."
fi

success "WireGuard installed via ${PKG_MGR}."

info "Generating WireGuard key pair…"

WG_DIR="/etc/wireguard"
mkdir -p "$WG_DIR"
chmod 700 "$WG_DIR"

CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

success "Key pair generated."

CONFIG_FILE="${WG_DIR}/wg0.conf"
info "Writing config to ${CONFIG_FILE}…"

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
success "Config written."

echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}Thank you for using Serververse™ Network Transit!${NC}"
echo ""
echo -e "  Your WireGuard Client has been configured successfully."
echo -e "  ${DIM}The tunnel has NOT been started. Contact your administrator when ready.${NC}"
echo ""
echo -e "  ${BOLD}Your Client Public Key:${NC}"
echo ""
echo -e "  ${YELLOW}${BOLD}  ${CLIENT_PUBLIC_KEY}${NC}"
echo ""
echo -e "  ${CYAN}Please provide this public key to the Serververse™ Team so they"
echo -e "  can add your peer to the server before you bring the tunnel up.${NC}"
echo ""
echo -e "  ${DIM}When you are cleared to connect, bring the tunnel up with:${NC}"
echo -e "  ${DIM}  sudo wg-quick up wg0  && systemctl enable wg-quick@wg0${NC}"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
