#!/bin/sh
# Transparent bypass: redsocks + iptables -> SOCKS5 at same-subnet .100:1070.
# Usage: bypass-proxy.sh start | stop
# Run with sudo. Requires: redsocks, iptables.
PATH="/usr/sbin:/sbin:$PATH"
export PATH

REDSOCKS_CONF="/etc/redsocks-bypass.conf"
REDSOCKS_PORT=12345
SOCKS_PORT=1070
CHAIN="REDSOCKS"

get_socks_ip() {
  # Same subnet .100 (soft router WAN)
  local ip
  ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4; exit}' | cut -d'/' -f1)
  [ -z "$ip" ] && ip=$(ip -4 route get 8.8.8.8 2>/dev/null | awk '{print $6; exit}')
  [ -n "$ip" ] && echo "$ip" | cut -d. -f1-3 | sed 's/$/.100/'
}

start() {
  SOCKS_IP=$(get_socks_ip)
  [ -z "$SOCKS_IP" ] && echo "Cannot get SOCKS server (.100)" && return 1

  if ! command -v redsocks >/dev/null 2>&1; then
    echo "redsocks not installed. Run: sudo apt-get install redsocks"
    return 1
  fi

  cat > "$REDSOCKS_CONF" << EOF
base {
  log_debug = off;
  log_info = on;
  daemon = on;
  redirector = iptables;
}
redsocks {
  local_ip = 127.0.0.1;
  local_port = $REDSOCKS_PORT;
  ip = $SOCKS_IP;
  port = $SOCKS_PORT;
  type = socks5;
}
EOF

  # Avoid redirecting traffic to the SOCKS server itself
  IPT="/usr/sbin/iptables"
  $IPT -t nat -N "$CHAIN" 2>/dev/null || true
  $IPT -t nat -F "$CHAIN"
  $IPT -t nat -A "$CHAIN" -d 0.0.0.0/8 -j RETURN
  $IPT -t nat -A "$CHAIN" -d 10.0.0.0/8 -j RETURN
  $IPT -t nat -A "$CHAIN" -d 127.0.0.0/8 -j RETURN
  $IPT -t nat -A "$CHAIN" -d 169.254.0.0/16 -j RETURN
  $IPT -t nat -A "$CHAIN" -d 172.16.0.0/12 -j RETURN
  $IPT -t nat -A "$CHAIN" -d 192.168.0.0/16 -j RETURN
  $IPT -t nat -A "$CHAIN" -d "$SOCKS_IP" -j RETURN
  $IPT -t nat -A "$CHAIN" -p tcp -j REDIRECT --to-ports "$REDSOCKS_PORT"
  $IPT -t nat -D OUTPUT -p tcp -j "$CHAIN" 2>/dev/null || true
  $IPT -t nat -A OUTPUT -p tcp -j "$CHAIN"

  pkill -x redsocks 2>/dev/null || true
  sleep 1
  redsocks -c "$REDSOCKS_CONF"
  echo "bypass-proxy started (SOCKS $SOCKS_IP:$SOCKS_PORT)"
}

stop() {
  IPT="/usr/sbin/iptables"
  $IPT -t nat -D OUTPUT -p tcp -j "$CHAIN" 2>/dev/null || true
  $IPT -t nat -F "$CHAIN" 2>/dev/null || true
  pkill -x redsocks 2>/dev/null || true
  echo "bypass-proxy stopped"
}

case "${1:-}" in
  start) start ;;
  stop)  stop ;;
  *)     echo "Usage: $0 start|stop"; exit 1 ;;
esac
