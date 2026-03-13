#!/bin/sh
# Set default gateway to same subnet .100 (soft router WAN).
# Requires main router to give soft router WAN a reserved IP ending in .100.

IFACE="${1:-eth0}"
sleep 3
IP=$(ip -4 -o addr show "$IFACE" 2>/dev/null | awk '{print $4}' | cut -d'/' -f1)
[ -z "$IP" ] && exit 0
GW=$(echo "$IP" | cut -d. -f1-3).100
ip route del default 2>/dev/null || true
ip route add default via "$GW" dev "$IFACE" 2>/dev/null || true
[ "$(id -u)" = "0" ] && echo "nameserver $GW" >/etc/resolv.conf 2>/dev/null || true
exit 0
