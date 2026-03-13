#!/bin/sh
# Control bypass proxy (redsocks + SOCKS5 via soft router).
# Usage: bypass-ctl.sh status|enable|disable
# Run with sudo.

status() {
  if iptables -t nat -L OUTPUT -n 2>/dev/null | grep -q REDSOCKS; then
    echo "enabled"
  else
    echo "disabled"
  fi
}

enable_bypass() {
  /usr/local/bin/bypass-proxy.sh start
}

disable_bypass() {
  /usr/local/bin/bypass-proxy.sh stop
}

case "${1:-status}" in
  status) status ;;
  enable) enable_bypass ;;
  disable) disable_bypass ;;
  *) echo "usage: $0 status|enable|disable"; exit 1 ;;
esac
