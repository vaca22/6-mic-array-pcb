#!/bin/sh
# Shutdown or reboot. Usage: pi-power.sh shutdown | reboot
# Install to /usr/local/bin/, allow: pi ALL=(ALL) NOPASSWD: /usr/local/bin/pi-power.sh
case "${1:-}" in
  shutdown) exec /usr/sbin/shutdown -h now ;;
  reboot)   exec /usr/sbin/reboot ;;
  *)        echo "Usage: $0 shutdown|reboot"; exit 1 ;;
esac
