#!/usr/bin/env bash

set -euo pipefail

function main() {
  case "${1:-}" in
  -h | --help) usage; return ;;
  prepare | cleanup) [[ $# -eq 1 ]] || die "Expected one subcommand" ;;
  *) usage; die "Expected prepare or cleanup" ;;
  esac

  local dump="${IMMICH_DUMP_FILE:?}"
  local marker
  marker="$(dirname "$dump")/restart-immich"

  case "$1" in
  prepare)
    [[ -n "$(immich-compose ps --status running -q immich-server)" ]] || die "Immich is not running"
    touch "$marker"
    immich-compose stop --timeout 120 immich-server
    umask 077
    immich-compose exec -T database pg_dump --clean --if-exists --username=immich --dbname=immich > "$dump.tmp"
    mv "$dump.tmp" "$dump"
    ;;
  cleanup)
    if [[ -e "$marker" ]]; then
      immich-compose start --wait --wait-timeout 600 immich-server
      rm "$marker"
    fi
    rm -f "$dump.tmp"
    ;;
  esac
}

usage() {
  echo "Usage: $(basename "$0") prepare|cleanup"
}

die() {
  echo "Error: $1" >&2
  exit 1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
