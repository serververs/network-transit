#!/usr/bin/env bash
#
# Installs the `sv-transit` command, then hands over to it.
#
#   sudo bash install.sh --token <token>             install the tunnel
#   sudo bash install.sh --migrate --token <token>   migrate an existing WireGuard setup
#   sudo bash install.sh --remove                    uninstall the tunnel
#
# Every flag is passed through to `sv-transit`, so this is the same as running
# `sv-transit install|migrate|uninstall` once the command is on the machine.

CLI_URL='__CLI_URL__'
CLI_PATH="/usr/local/bin/sv-transit"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "  ${CYAN}${BOLD}→${NC}  $*"; }
success() { echo -e "  ${GREEN}${BOLD}✔${NC}  $*"; }
die()     { echo -e "\n  ${RED}${BOLD}✘  ERROR:${NC} $*\n" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "Run as root (sudo required)."
command -v curl &>/dev/null || die "curl is required. Install it with: apt-get install -y curl"

command="install"
args=()
for arg in "$@"; do
  case "${arg}" in
    --remove|--uninstall) command="uninstall" ;;
    --migrate)            command="migrate" ;;
    *)                    args+=("${arg}") ;;
  esac
done

echo ""
info "Installing the sv-transit command..."

tmp_file=$(mktemp)
trap 'rm -f "${tmp_file}"' EXIT

curl -fsSL --max-time 30 --retry 2 -o "${tmp_file}" "${CLI_URL}" \
  || die "Could not download the sv-transit command. Is the API reachable?"
head -n1 "${tmp_file}" | grep -q '^#!' \
  || die "The download did not look like a script."

install -m 755 "${tmp_file}" "${CLI_PATH}" || die "Could not write ${CLI_PATH}."
success "Installed ${CLI_PATH} ($(${CLI_PATH} version))."

if [[ $# -eq 0 ]]; then
  echo ""
  echo -e "  Run ${BOLD}sudo sv-transit install --token <token>${NC} to set up your tunnel."
  echo -e "  ${DIM}See: sv-transit help${NC}"
  echo ""
  exit 0
fi

exec "${CLI_PATH}" "${command}" "${args[@]}"
