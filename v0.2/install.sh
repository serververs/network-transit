#!/usr/bin/env bash
set -euo pipefail

VERSION="latest"
REDEEM_URL=""
WG_IFACE="sv-transit"
WG_DIR="/etc/wireguard"
CONFIG_FILE="${WG_DIR}/${WG_IFACE}.conf"

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
die()     { echo -e "\n  ${RED}${BOLD}✘  ERROR:${NC} $*\n" >&2; exit 1; }

log() {
  while IFS= read -r line; do
    echo -e "  ${DIM}     ${line}${NC}"
  done
}

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

usage() {
  echo ""
  echo -e "  ${BOLD}Usage:${NC}"
  echo "    sudo bash $0 --token <provisioning-token>"
  echo "    sudo bash $0 --remove"
  echo "    sudo bash $0 --version"
  echo ""
  exit 1
}

TOKEN=""
REMOVE_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --token)   TOKEN="$2"; shift 2 ;;
    --token=*) TOKEN="${1#*=}"; shift ;;
    --remove) REMOVE_MODE=true; shift ;;
    --version) echo "Serververse Transit ${VERSION}"; exit 0 ;;
    -h|--help) usage ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ "${EUID}" -ne 0 ]] && die "Run as root (sudo required)."

print_banner

if ${REMOVE_MODE}; then
  warn "Uninstall mode triggered..."
  wg-quick down "${WG_IFACE}" 2>/dev/null || true
  systemctl disable "wg-quick@${WG_IFACE}" 2>/dev/null || true
  rm -f "${CONFIG_FILE}"
  success "Serververse Network Transit has been removed."
  exit 0
fi

[[ -z "${TOKEN}" ]] && die "--token is required."

echo -e "  ${BOLD}Welcome to Serververse Network Transit${NC}"
echo ""
echo -e "  This installer will configure a tunnel to the Serververse Transit Network on this machine."
echo ""
echo -e "  ${GREEN}${BOLD}Note:${NC} ${CYAN}Serververse Transit is currently in beta. Bugs, instability, or unexpected behavior may occur.${NC}"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Terms of Service & Acceptable Use Policy${NC}"
echo ""
echo -e "  By continuing you confirm that:"
echo -e "    ${DIM}1.${NC}  You are an authorised Serververse user."
echo -e "    ${DIM}2.${NC}  You will not use this tunnel for unlawful, abusive, or harmful activity."
echo -e "    ${DIM}3.${NC}  You accept Serververse's Terms of Service and Privacy Policy:"
echo -e "        ${CYAN}https://serververs.com/tos${NC}"
echo -e "        ${CYAN}https://serververs.com/privacy${NC}"
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
echo -e "  ${BOLD}Configuring network transit...${NC}"
echo ""

install_dependencies() {
  info "Detecting package manager..."

  if command -v apt-get &>/dev/null; then
    info "Updating package lists..."
    apt-get update 2>&1 | log
    info "Installing Transit Manager..."
    apt-get install -y resolvconf wireguard-tools curl iptables 2>&1 | log
    success "Transit Manager installed via apt-get."
  else
    die "No supported package manager found. Ubuntu and Debian based distributions are supported for now."
  fi
}

redeem_config() {
  local output_file="$1"
  local http_code

  info "Redeeming provisioning token..."

  http_code=$(curl -sS -o "${output_file}" -w "%{http_code}" -X POST "${REDEEM_URL}" \
    -H "Content-Type: application/json" \
    -d "{\"token\": \"${TOKEN}\"}") || die "Token redemption request failed. Is the API reachable?"

  if [[ "${http_code}" != "200" ]]; then
    local err_msg
    err_msg=$(grep -oE '"message"[[:space:]]*:[[:space:]]*"[^"]+"' "${output_file}" 2>/dev/null | sed -E 's/.*"message"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)
    [[ -z "${err_msg}" ]] && err_msg="Unknown error"
    rm -f "${output_file}"
    die "Token redemption failed (HTTP ${http_code}): ${err_msg}"
  fi

  grep -q "\[Interface\]" "${output_file}" || die "Received response does not look like a WireGuard config."
  grep -q "\[Peer\]" "${output_file}" || die "Received config is missing a WireGuard peer section."
}

normalize_config() {
  local input_file="$1"
  local output_file="$2"

  sed -E \
    -e "s/default dev [^ ]+ table/default dev ${WG_IFACE} table/g" \
    -e "s/-o [^ ]+ -j SNAT/-o ${WG_IFACE} -j SNAT/g" \
    "${input_file}" > "${output_file}"
}

write_and_activate() {
  local redeemed_file
  local normalized_file
  redeemed_file=$(mktemp)
  normalized_file=$(mktemp)

  redeem_config "${redeemed_file}"
  normalize_config "${redeemed_file}" "${normalized_file}"

  mkdir -p "${WG_DIR}"
  chmod 700 "${WG_DIR}"

  if [[ -f "${CONFIG_FILE}" ]]; then
    local backup
    backup="${CONFIG_FILE}.bak.$(date +%s)"
    warn "Existing config found. Backing up to ${backup}"
    mv "${CONFIG_FILE}" "${backup}"
  fi

  if systemctl is-active --quiet "wg-quick@wg0" 2>/dev/null; then
    warn "Stopping old wg0 tunnel before starting ${WG_IFACE}..."
    systemctl stop "wg-quick@wg0" 2>&1 | log || true
  elif ip link show wg0 &>/dev/null; then
    warn "Stopping old wg0 tunnel before starting ${WG_IFACE}..."
    wg-quick down wg0 2>&1 | log || true
  fi

  info "Writing config to ${CONFIG_FILE}..."
  install -m 600 "${normalized_file}" "${CONFIG_FILE}"
  rm -f "${redeemed_file}" "${normalized_file}"
  success "Config written."

  if systemctl is-active --quiet "wg-quick@${WG_IFACE}" 2>/dev/null; then
    info "Stopping existing ${WG_IFACE} tunnel..."
    systemctl stop "wg-quick@${WG_IFACE}" 2>&1 | log || true
  fi

  info "Booting Serververse Network Transit..."
  wg-quick up "${WG_IFACE}" 2>&1 | log
  systemctl enable "wg-quick@${WG_IFACE}" 2>&1 | log

  success "Tunnel ${WG_IFACE} is active."
}

install_dependencies
write_and_activate

PUBLIC_IP=$(grep -oE 'PostUp[[:space:]]*= ip addr add [0-9.]+/32 dev lo' "${CONFIG_FILE}" | head -1 | grep -oE '[0-9.]+/32' | sed 's#/32##' || true)

echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}Thank you for using Serververse Network Transit!${NC}"
echo ""
echo -e "  Your tunnel has been configured successfully."
echo ""
[[ -n "${PUBLIC_IP}" ]] && echo -e "    ${DIM}Public IP     :${NC}  ${PUBLIC_IP}"
echo -e "    ${DIM}Interface     :${NC}  ${WG_IFACE}"
echo -e "    ${DIM}Config        :${NC}  ${CONFIG_FILE}"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
