#!/usr/bin/env bash

set -euo pipefail

function main() {
  case "${1:-}" in
  -h | --help) usage; return ;;
  "") usage; die "Expected a failed service name" ;;
  esac
  [[ $# -eq 1 ]] || die "Expected one service name"
  : "${ALERT_FROM:?}" "${ALERT_TO:?}" "${ALERT_HOST:?}"
  local service="$1"

  {
    printf 'From: %s\nTo: %s\n' "$ALERT_FROM" "$ALERT_TO"
    printf 'Subject: [%s] Service failed: %s\n' "$ALERT_HOST" "$service"
    printf 'Date: %s\nContent-Type: text/plain; charset=UTF-8\n\n' "$(LC_ALL=C date -R)"
    printf '%s failed on %s.\n\n' "$service" "$ALERT_HOST"
    systemctl show "$service" --property=Result,ExecMainCode,ExecMainStatus --no-pager || true
    printf '\nInspect with:\nssh %s '\''sudo journalctl -u %s -n 50 --no-pager'\''\n' "$ALERT_HOST" "$service"
  } | msmtp --account=default -- "$ALERT_TO"
}

usage() {
  echo "Usage: $(basename "$0") SERVICE"
}

die() {
  echo "Error: $1" >&2
  exit 1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
