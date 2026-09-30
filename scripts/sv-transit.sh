#!/usr/bin/env bash
#
# sv-transit — command line tool for Serververse Network Transit.
#
#   sudo sv-transit install --token <token>
#   sudo sv-transit migrate --token <token>
#   sudo sv-transit uninstall
#   sudo sv-transit status
#
# Each command is a cmd_<name> function; add a function and a line in main()
# to add a command.

VERSION="0.3"
REDEEM_URL='__REDEEM_URL__'
TERMS_URL='__TERMS_URL__'
PRIVACY_URL='__PRIVACY_URL__'
WG_IFACE="sv-transit"
WG_DIR="/etc/wireguard"
CONFIG_FILE="${WG_DIR}/${WG_IFACE}.conf"
CLI_PATH="/usr/local/bin/sv-transit"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

RULE="  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

info()    { echo -e "  ${CYAN}${BOLD}→${NC}  $*"; }
success() { echo -e "  ${GREEN}${BOLD}✔${NC}  $*"; }
warn()    { echo -e "  ${YELLOW}${BOLD}!${NC}  $*"; }
die()     { echo -e "\n  ${RED}${BOLD}✘  ERROR:${NC} $*\n" >&2; exit 1; }

log() {
  while IFS= read -r line; do
    printf '  %b     %s%b\n' "${DIM}" "${line}" "${NC}"
  done
}

run() {
  "$@" 2>&1 | log
  [[ ${PIPESTATUS[0]} -eq 0 ]] || die "Command failed: $*"
}

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo sv-transit $COMMAND"
}

# A Serververse node (the machine running serververse-daemon) keeps its own
# WireGuard server config at the same path and interface name this tool writes
# a customer tunnel to, so running install, migrate or uninstall there would
# wipe the node's server config and take the node down.
refuse_on_node() {
  if systemctl cat serververse-daemon.service &>/dev/null; then
    die "This machine runs the Serververse daemon, so it is a transit node, not a customer machine. ${COMMAND} would overwrite the node's own WireGuard config (${CONFIG_FILE}). Run it on the customer machine instead."
  fi
}

ask() {
  echo -en "$1"
  read -r ANSWER 2>/dev/null </dev/tty || die "No terminal to ask on. $2"
  echo ""
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
  echo -e "${RULE}"
  echo ""
}

usage() {
  echo ""
  echo -e "  ${BOLD}Serververse Network Transit${NC} v${DIM}${VERSION}${NC}"
  echo ""
  echo -e "  ${BOLD}Usage:${NC}"
  echo "    sudo sv-transit install --token <provisioning-token> [--yes]"
  echo "    sudo sv-transit migrate --token <provisioning-token>"
  echo "    sudo sv-transit uninstall [--purge]"
  echo "    sudo sv-transit status"
  echo "    sv-transit version"
  echo ""
  echo -e "  ${BOLD}Commands:${NC}"
  echo "    install     Set up the tunnel on this machine."
  echo "    migrate     Stop every WireGuard tunnel here, clear ${WG_DIR}, then install."
  echo "                Do not run this over a connection that uses the transit IP."
  echo "    uninstall   Remove the tunnel (alias: remove). --purge also removes this command."
  echo "                Do not run this over a connection that uses the transit IP."
  echo "    status      Show whether the tunnel is up and when it last shook hands."
  echo "    version     Print the version."
  echo ""
  echo -e "  ${BOLD}Options:${NC}"
  echo "    --yes       Accept the Terms of Service without asking. Never skips"
  echo "                the migrate or uninstall warnings."
  echo ""
  exit "${1:-0}"
}

TOKEN=""
ASSUME_YES=false
PURGE=false
MIGRATE_MODE=false
WG_BACKUP=""

parse_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --token)   [[ $# -ge 2 ]] || die "--token needs a value."; TOKEN="$2"; shift 2 ;;
      --token=*) TOKEN="${1#*=}"; shift ;;
      -y|--yes)  ASSUME_YES=true; shift ;;
      --purge)   PURGE=true; shift ;;
      -h|--help) usage 0 ;;
      *) die "Unknown option: $1 (try: sv-transit help)" ;;
    esac
  done
}
transit_addresses() {
  local conf
  for conf in "${WG_DIR}"/*.conf; do
    [[ -f "${conf}" ]] || continue
    sed -nE 's/^[[:space:]]*PostUp[[:space:]]*=[[:space:]]*ip addr add ([0-9.]+).*/\1/p' "${conf}"
    sed -nE 's/^[[:space:]]*Address[[:space:]]*=[[:space:]]*([0-9.]+).*/\1/p' "${conf}"
  done
}

on_transit_ip() {
  local dest lo known
  dest=$(awk '{print $3}' <<<"${SSH_CONNECTION:-}")
  [[ -n "${dest}" ]] || return 1

  lo=$(ip -o addr show dev lo 2>/dev/null)
  [[ "${dest}" != 127.* && "${lo}" == *"inet ${dest}/"* ]] && return 0

  known=$(transit_addresses)
  [[ $'\n'"${known}"$'\n' == *$'\n'"${dest}"$'\n'* ]]
}

confirm_migrate() {
  echo -e "  ${RED}${BOLD}Migrate replaces every WireGuard tunnel on this machine${NC}"
  echo ""
  echo -e "  This will, in order:"
  echo -e "    ${DIM}1.${NC}  Stop ${BOLD}all${NC} WireGuard tunnels and disable them at boot."
  echo -e "    ${DIM}2.${NC}  Back up ${BOLD}${WG_DIR}${NC} to /root, then clear it."
  echo -e "    ${DIM}3.${NC}  Install your Serververse tunnel from scratch."
  echo ""
  echo -e "  ${RED}${BOLD}If you are connected to this machine through the transit IP, or any${NC}"
  echo -e "  ${RED}${BOLD}other WireGuard tunnel, you will be disconnected${NC} the moment it stops"
  echo -e "  and the install may not finish."
  echo ""
  echo -e "  Migrate from a different connection instead: your provider's web console,"
  echo -e "  VNC or serial console, or SSH over an address that does not use the transit IP."
  echo ""
  echo -e "${RULE}"
  echo ""

  if on_transit_ip; then
    die "This SSH session arrives on a tunnel address, so migrating from here would cut you off. Reconnect another way and run migrate again."
  fi

  warn "Warning 1 of 2: stopping WireGuard disconnects anyone on the transit IP."
  echo ""
  ask "  Continue? [yes/no]: " "Migrate needs an interactive terminal."
  case "${ANSWER,,}" in
    yes|y) ;;
    *) echo -e "  Migration cancelled. No changes were made.\n"; exit 1 ;;
  esac

  warn "Warning 2 of 2: last chance. Are you sure this is NOT a transit connection?"
  echo ""
  ask "  Type MIGRATE to confirm: " "Migrate needs an interactive terminal."
  if [[ "${ANSWER}" != "MIGRATE" ]]; then
    echo -e "  Migration cancelled. No changes were made.\n"
    exit 1
  fi

  echo -e "${RULE}"
  echo ""
}

confirm_uninstall() {
  echo -e "  ${RED}${BOLD}Uninstall removes the Serververse tunnel from this machine${NC}"
  echo ""
  echo -e "  This will, in order:"
  echo -e "    ${DIM}1.${NC}  Stop the ${BOLD}${WG_IFACE}${NC} tunnel and disable it at boot."
  echo -e "    ${DIM}2.${NC}  Delete ${BOLD}${CONFIG_FILE}${NC}."
  echo ""
  echo -e "  ${RED}${BOLD}If you are connected to this machine through the transit IP, you will be${NC}"
  echo -e "  ${RED}${BOLD}disconnected${NC} the moment the tunnel stops, and you will not be able to"
  echo -e "  reconnect over that IP."
  echo ""
  echo -e "  Uninstall from a different connection instead: your provider's web console,"
  echo -e "  VNC or serial console, or SSH over an address that does not use the transit IP."
  echo ""
  echo -e "${RULE}"
  echo ""

  if on_transit_ip; then
    die "This SSH session arrives on a tunnel address, so uninstalling from here would cut you off. Reconnect another way and run uninstall again."
  fi

  warn "Warning 1 of 2: stopping the tunnel disconnects anyone on the transit IP."
  echo ""
  ask "  Continue? [yes/no]: " "Uninstall needs an interactive terminal."
  case "${ANSWER,,}" in
    yes|y) ;;
    *) echo -e "  Uninstall cancelled. No changes were made.\n"; exit 1 ;;
  esac

  warn "Warning 2 of 2: last chance. Are you sure this is NOT a transit connection?"
  echo ""
  ask "  Type UNINSTALL to confirm: " "Uninstall needs an interactive terminal."
  if [[ "${ANSWER}" != "UNINSTALL" ]]; then
    echo -e "  Uninstall cancelled. No changes were made.\n"
    exit 1
  fi

  echo -e "${RULE}"
  echo ""
}

stop_all_wireguard() {
  local iface unit conf

  info "Stopping every WireGuard tunnel on this machine..."

  for iface in $(wg show interfaces 2>/dev/null); do
    if [[ -f "${WG_DIR}/${iface}.conf" ]]; then
      wg-quick down "${iface}" 2>&1 | log || true
    else
      ip link delete dev "${iface}" 2>&1 | log || true
    fi
  done

  for unit in $(systemctl list-units --all --plain --no-legend 'wg-quick@*' 2>/dev/null | awk '{print $1}'); do
    systemctl disable --now "${unit}" 2>&1 | log || true
  done
  for conf in "${WG_DIR}"/*.conf; do
    [[ -f "${conf}" ]] || continue
    systemctl disable "wg-quick@$(basename "${conf}" .conf)" 2>&1 | log || true
  done

  [[ -z "$(wg show interfaces 2>/dev/null)" ]] || die "Could not stop: $(wg show interfaces)"
  success "WireGuard stopped."
}

clear_wg_dir() {
  info "Clearing ${WG_DIR}..."

  if [[ -z "$(ls -A "${WG_DIR}" 2>/dev/null)" ]]; then
    success "${WG_DIR} is already empty."
    return
  fi

  WG_BACKUP="/root/wireguard-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
  (umask 077 && tar -czf "${WG_BACKUP}" -C "$(dirname "${WG_DIR}")" "$(basename "${WG_DIR}")") \
    || die "Could not back up ${WG_DIR}. Nothing was deleted."
  find "${WG_DIR}" -mindepth 1 -delete || die "Could not clear ${WG_DIR}."
  success "Cleared. Old config backed up to ${WG_BACKUP}"
}


accept_terms() {
  echo -e "  ${BOLD}Welcome to Serververse Network Transit${NC}"
  echo ""
  echo -e "  This installer will configure a tunnel to the Serververse Transit Network on this machine."
  echo ""
  echo -e "  ${GREEN}${BOLD}Note:${NC} ${CYAN}Serververse Transit is currently in beta. Bugs, instability, or unexpected behavior may occur.${NC}"
  echo ""
  echo -e "${RULE}"
  echo ""
  echo -e "  ${BOLD}Terms of Service & Acceptable Use Policy${NC}"
  echo ""
  echo -e "  By continuing you confirm that:"
  echo -e "    ${DIM}1.${NC}  You are an authorised Serververse user."
  echo -e "    ${DIM}2.${NC}  You will not use this tunnel for unlawful, abusive, or harmful activity."
  echo -e "    ${DIM}3.${NC}  You accept Serververse's Terms of Service and Privacy Policy:"
  [[ -n "${TERMS_URL}" ]]   && echo -e "        ${CYAN}${TERMS_URL}${NC}"
  [[ -n "${PRIVACY_URL}" ]] && echo -e "        ${CYAN}${PRIVACY_URL}${NC}"
  echo ""
  echo -e "${RULE}"
  echo ""

  if ${ASSUME_YES}; then
    success "Terms accepted (--yes). Proceeding with setup."
    return
  fi

  ask "  Do you agree to the Terms of Service and Acceptable Use Policy? [yes/no]: " "Re-run with --yes to accept the terms."
  case "${ANSWER,,}" in
    yes|y) success "Terms accepted. Proceeding with setup." ;;
    *)
      warn "You must accept the Terms of Service and Privacy Policy to continue."
      echo -e "\n  Setup aborted. No changes were made to this system.\n"
      exit 1
      ;;
  esac
}

install_dependencies() {
  info "Detecting package manager..."

  if command -v apt-get &>/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    info "Updating package lists..."
    run apt-get update
    info "Installing Transit Manager..."
    run apt-get install -y resolvconf wireguard-tools curl iptables
    success "Transit Manager installed via apt-get."
  else
    die "Unsupported system: this installer needs apt-get, so it only supports Debian and Ubuntu."
  fi
}

redeem_config() {
  local output_file="$1"
  local http_code

  info "Redeeming provisioning token..."

  http_code=$(printf '{"token": "%s"}' "${TOKEN}" | curl -sS -o "${output_file}" -w "%{http_code}" -X POST "${REDEEM_URL}" \
    -H "Content-Type: application/json" \
    --data-binary @-) || die "Token redemption request failed. Is the API reachable?"

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
  redeemed_file=$(mktemp)
  normalized_file=$(mktemp)
  trap 'rm -f "${redeemed_file}" "${normalized_file}"' EXIT

  redeem_config "${redeemed_file}"
  normalize_config "${redeemed_file}" "${normalized_file}"

  if ${MIGRATE_MODE}; then
    stop_all_wireguard
    clear_wg_dir
  fi

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

  local sub_bridge
  sub_bridge=$(subnet_field "${normalized_file}" bridge)
  if [[ -n "${sub_bridge}" ]] && ! ip link show "${sub_bridge}" &>/dev/null; then
    die "This subnet attaches to the bridge '${sub_bridge}', but no interface with that name exists on this machine. Create it first (for example: ip link add ${sub_bridge} type bridge && ip link set ${sub_bridge} up), or ask support to change the interface name, then run the install again."
  fi

  info "Writing config to ${CONFIG_FILE}..."
  install -m 600 "${normalized_file}" "${CONFIG_FILE}" || die "Could not write ${CONFIG_FILE}."
  success "Config written."

  if systemctl is-active --quiet "wg-quick@${WG_IFACE}" 2>/dev/null; then
    info "Stopping existing ${WG_IFACE} tunnel..."
    systemctl stop "wg-quick@${WG_IFACE}" 2>&1 | log || true
  fi

  info "Booting Serververse Network Transit..."
  wg-quick up "${WG_IFACE}" 2>&1 | log
  if ! ip link show "${WG_IFACE}" &>/dev/null; then
    [[ -n "${WG_BACKUP}" ]] && warn "Your previous WireGuard config is backed up at ${WG_BACKUP}"
    die "The tunnel did not come up. Check the output above."
  fi
  systemctl enable "wg-quick@${WG_IFACE}" 2>&1 | log

  success "Tunnel ${WG_IFACE} is active."
}

public_ip() {
  grep -oE 'PostUp[[:space:]]*= ip addr add [0-9.]+/32 dev lo' "${CONFIG_FILE}" 2>/dev/null \
    | head -1 | grep -oE '[0-9.]+/32' | sed 's#/32##' || true
}

# Value of `key` from the "# sv-transit-subnet:" line the node writes into a routed-subnet config.
subnet_field() {
  local file="$1" key="$2"
  grep -m1 '^# sv-transit-subnet:' "${file}" 2>/dev/null | tr ' ' '\n' | grep "^${key}=" | head -1 | cut -d= -f2-
}

# Routed-subnet details: usable range, the bridge the VMs attach to, and the gateway they use.
print_subnet_details() {
  local file="$1" cidr bridge address gateway first last netmask prefix
  cidr=$(subnet_field "${file}" cidr)
  [[ -n "${cidr}" ]] || return 0
  bridge=$(subnet_field "${file}" bridge)
  address=$(subnet_field "${file}" address)
  gateway=$(subnet_field "${file}" gateway)
  first=$(subnet_field "${file}" first)
  last=$(subnet_field "${file}" last)
  netmask=$(subnet_field "${file}" netmask)
  prefix="${cidr#*/}"

  echo -e "    ${DIM}Subnet        :${NC}  ${cidr}"
  echo -e "    ${DIM}Usable IPs    :${NC}  ${first} - ${last}"
  echo -e "    ${DIM}Bridge        :${NC}  ${bridge}  (${address})"
  echo -e "    ${DIM}Gateway       :${NC}  ${gateway}"
  echo -e "    ${DIM}Netmask       :${NC}  ${netmask}  (/${prefix})"
  echo ""
  echo -e "  ${DIM}Inside your VMs:${NC} attach them to ${BOLD}${bridge}${NC}, use an address from the usable range,"
  echo -e "  netmask ${netmask} and gateway ${BOLD}${gateway}${NC}. ${DIM}(${gateway} is the bridge's own address on this host.)${NC}"
}

print_summary() {
  local ip
  ip=$(public_ip)

  echo ""
  echo -e "${RULE}"
  echo ""
  echo -e "  ${GREEN}${BOLD}Thank you for using Serververse Network Transit!${NC}"
  echo ""
  echo -e "  Your tunnel has been configured successfully."
  echo ""
  [[ -n "${ip}" ]] && echo -e "    ${DIM}Public IP     :${NC}  ${ip}"
  echo -e "    ${DIM}Interface     :${NC}  ${WG_IFACE}"
  echo -e "    ${DIM}Config        :${NC}  ${CONFIG_FILE}"
  [[ -n "${WG_BACKUP}" ]] && echo -e "    ${DIM}Old WireGuard :${NC}  ${WG_BACKUP}"
  print_subnet_details "${CONFIG_FILE}"
  echo ""
  echo -e "  ${DIM}Check on it any time with:${NC}  sudo sv-transit status"
  echo -e "  ${DIM}View more details of the commands:${NC}  sudo sv-transit help"
  echo ""
  echo -e "${RULE}"
  echo ""
}


cmd_install() {
  parse_options "$@"
  require_root
  refuse_on_node
  print_banner

  [[ -n "${TOKEN}" ]] || die "--token is required."
  [[ "${MIGRATE_MODE}" == true ]] && confirm_migrate

  accept_terms

  echo ""
  echo -e "${RULE}"
  echo ""
  echo -e "  ${BOLD}Configuring network transit...${NC}"
  echo ""

  install_dependencies
  write_and_activate
  print_summary
}

cmd_migrate() {
  MIGRATE_MODE=true
  cmd_install "$@"
}

cmd_uninstall() {
  parse_options "$@"
  require_root
  refuse_on_node
  print_banner

  if [[ ! -f "${CONFIG_FILE}" ]] && ! ip link show "${WG_IFACE}" &>/dev/null; then
    warn "Serververse Transit is not installed on this machine. Nothing to remove."
    echo ""
    exit 0
  fi

  confirm_uninstall

  warn "Uninstall mode triggered..."
  wg-quick down "${WG_IFACE}" 2>/dev/null || true
  systemctl disable "wg-quick@${WG_IFACE}" 2>/dev/null || true
  rm -f "${CONFIG_FILE}"
  success "Serververse Network Transit has been removed."

  if ${PURGE}; then
    rm -f "${CLI_PATH}"
    success "Removed ${CLI_PATH}."
  else
    echo -e "  ${DIM}The sv-transit command was kept. Add --purge to remove it too.${NC}"
  fi
  echo ""
}

cmd_status() {
  require_root
  echo ""

  if [[ ! -f "${CONFIG_FILE}" ]]; then
    warn "Serververse Transit is not installed on this machine."
    echo ""
    exit 1
  fi
  if ! ip link show "${WG_IFACE}" &>/dev/null; then
    warn "The tunnel ${WG_IFACE} is not running. Start it with: sudo systemctl start wg-quick@${WG_IFACE}"
    echo ""
    exit 1
  fi

  local ip handshake ago transfer enabled
  ip=$(public_ip)
  handshake=$(wg show "${WG_IFACE}" latest-handshakes | awk '{print $2}' | sort -n | tail -n1)
  transfer=$(wg show "${WG_IFACE}" transfer | awk '{rx+=$2; tx+=$3} END {printf "%d %d", rx, tx}')
  enabled=$(systemctl is-enabled "wg-quick@${WG_IFACE}" 2>/dev/null || echo "no")

  if [[ "${handshake:-0}" -gt 0 ]]; then
    ago=$(( $(date +%s) - handshake ))
    success "Tunnel ${WG_IFACE} is up. Last handshake ${ago}s ago."
  else
    warn "Tunnel ${WG_IFACE} is up, but no handshake yet. It can take a minute."
  fi

  echo ""
  [[ -n "${ip}" ]] && echo -e "    ${DIM}Public IP     :${NC}  ${ip}"
  echo -e "    ${DIM}Interface     :${NC}  ${WG_IFACE}"
  echo -e "    ${DIM}Start on boot :${NC}  ${enabled}"
  print_subnet_details "${CONFIG_FILE}"
  echo ""
}

main() {
  COMMAND="${1:-help}"
  [[ $# -gt 0 ]] && shift

  case "${COMMAND}" in
    install)          cmd_install "$@" ;;
    migrate)          cmd_migrate "$@" ;;
    uninstall|remove) cmd_uninstall "$@" ;;
    status)           cmd_status "$@" ;;
    version|--version|-v) echo "sv-transit ${VERSION}" ;;
    help|-h|--help)   usage 0 ;;
    *)                die "Unknown command: ${COMMAND} (try: sv-transit help)" ;;
  esac
}

main "$@"
