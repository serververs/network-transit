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
    echo -e "${BOLD}${YELLOW}"
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

UPSTREAM_KEY=""
UPSTREAM_IP=""
NODE_ADDR=""
UPSTREAM_PORT=""
EXTRA_IP=""
NODE_KEY=""

usage() {
    echo ""
    echo -e "  ${BOLD}Usage:${NC}"
    echo "    sudo bash $0 \\"
    echo "      --upstream-key   \\"
    echo "      --upstream-ip    \\"
    echo "      --upstream-port  \\"
    echo "      --node-addr      \\"
    echo "      --node-key       \\"
    echo "      --routed-ip      "
    echo ""
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --upstream-key)   UPSTREAM_KEY="$2";  shift 2 ;;
        --upstream-ip)    UPSTREAM_IP="$2";      shift 2 ;;
        --upstream-port)  UPSTREAM_PORT="$2";        shift 2 ;;
        --node-addr)      NODE_ADDR="$2";      shift 2 ;;
        --node-key)       NODE_KEY="$2";    shift 2 ;;
        --routed-ip)      EXTRA_IP="$2";       shift 2 ;;
        -h|--help)        usage ;;
        *) die "Unknown argument: $1"; usage ;;
    esac
done

[[ -z "$UPSTREAM_KEY" ]] && die "--upstream-key is required."
[[ -z "$UPSTREAM_IP"     ]] && die "--upstream-ip is required."
[[ -z "$UPSTREAM_PORT"       ]] && die "--upstream-port is required."
[[ -z "$NODE_ADDR"     ]] && die "--node-addr is required."
[[ -z "$EXTRA_IP"      ]] && die "--routed-ip is required."
[[ "$EUID" -ne 0 ]]       && die "This script must be run as root (use sudo)."

print_banner

echo -e "  ${BOLD}Welcome to Serververse Network Transit${NC}"
echo ""
echo -e "  This installer will configure a Tunnel to the Serververse Transit Network on this Machine."
echo ""
echo -e "  ${GREEN}${BOLD}Note:${NC} ${CYAN}Serververse Transit is currently in beta. Bugs, instability, or unexpected behavior may occur.${NC}"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Terms of Service & Acceptable Use Policy${NC}"
echo ""
echo -e "  By continuing you confirm that:"
echo -e "    ${DIM}1.${NC}  You are an authorised Serververse User."
echo -e "    ${DIM}2.${NC}  You will not use this tunnel for any unlawful, abusive, or harmful activity."
echo -e "    ${DIM}3.${NC}  You accept Serververse's full Terms of Service and Privacy Policy, available at ${CYAN}https://serververs.com/tos${NC} ${CYAN}https://serververs.com/privacy${NC}"
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

log() {
    while IFS= read -r line; do
        echo -e "  ${DIM}     ${line}${NC}"
    done
}

info "Detecting package manager…"

if command -v apt-get &>/dev/null; then
    PKG_MGR="apt-get"
    info "Updating package lists…"
    apt-get update 2>&1 | log
    info "Installing Transit Manager"
    apt-get install -y resolvconf wireguard-tools 2>&1 | log
else
# Ubuntu and debian / debian based distros supported for now!
    die "No supported package manager found (apt)."
fi

success "Transit Manager installed via ${PKG_MGR}."

WG_DIR="/etc/wireguard"
mkdir -p "$WG_DIR"
chmod 700 "$WG_DIR"

if [[ -n "$NODE_KEY" ]]; then
    info "Using provided node key…"
    CLIENT_NODE_KEY="$NODE_KEY"
    CLIENT_PUBLIC_KEY=$(echo "$CLIENT_NODE_KEY" | wg pubkey)
else
    info "Generating WireGuard key pair…"
    CLIENT_NODE_KEY=$(wg genkey)
    CLIENT_PUBLIC_KEY=$(echo "$CLIENT_NODE_KEY" | wg pubkey)
    success "Key pair generated."
fi

CONFIG_FILE="${WG_DIR}/wg0.conf"
info "Writing config to ${CONFIG_FILE}…"

cat > "$CONFIG_FILE" <<EOF
[Interface]
PrivateKey = ${CLIENT_NODE_KEY}
Address    = ${NODE_ADDR}
Table      = off
DNS        = 1.1.1.1,1.0.0.1

PostUp   = ip addr add ${EXTRA_IP}/32 dev lo || true
PostUp   = ip route add ${UPSTREAM_IP}/32 \$(ip route show default | awk 'NR==1{print "via", \$3, "dev", \$5}') || true
PostUp   = ip route add default dev wg0 table 200 || true
PostUp   = ip rule add from ${EXTRA_IP}/32 table 200 priority 100 || true

PostDown = ip addr del ${EXTRA_IP}/32 dev lo
PostDown = ip route del ${UPSTREAM_IP}/32 \$(ip route show default | awk 'NR==1{print "via", \$3, "dev", \$5}')
PostDown = ip route del default dev wg0 table 200
PostDown = ip rule del from ${EXTRA_IP}/32 table 200

[Peer]
PublicKey           = ${UPSTREAM_KEY}
Endpoint            = ${UPSTREAM_IP}:${UPSTREAM_PORT}
AllowedIPs          = 0.0.0.0/0
PersistentKeepalive = 25
EOF

info "Booting ServerVerse Network Transit!"
systemctl enable --now wg-quick@wg0  2>&1 | log

chmod 600 "$CONFIG_FILE"
success "Config written."


echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}Thank you for using Serververse Network Transit!${NC}"
echo ""
echo -e "  Your tunnel has been configured successfully."
echo ""
echo -e "    ${DIM}Public IP     :${NC}  ${EXTRA_IP}"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
