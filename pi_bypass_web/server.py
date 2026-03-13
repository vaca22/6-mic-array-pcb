#!/usr/bin/env python3
"""
Bypass gateway config web: toggle 旁路由 on/off, test Google.
Serves HTML and JSON API. Run on Raspberry Pi (port 8081).
"""
import subprocess
import json
import os
import socket
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

PORT = 8081
CTL = "/usr/local/bin/bypass-ctl.sh"
POWER = "/usr/local/bin/pi-power.sh"


def run_ctl(args):
    try:
        r = subprocess.run(
            ["sudo", CTL] + args,
            capture_output=True,
            text=True,
            timeout=10,
        )
        out = (r.stdout or "").strip()
        err = (r.stderr or "").strip()
        return r.returncode == 0, out, err
    except Exception as e:
        return False, "", str(e)


def run_power(action):
    try:
        r = subprocess.run(
            ["sudo", POWER, action],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return r.returncode == 0, (r.stdout or "").strip(), (r.stderr or "").strip()
    except Exception as e:
        return False, "", str(e)


def test_google():
    try:
        r = subprocess.run(
            [
                "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}",
                "--connect-timeout", "8", "https://www.google.com",
            ],
            capture_output=True,
            text=True,
            timeout=12,
        )
        code = (r.stdout or "").strip() or "000"
        return code == "200", code
    except Exception:
        return False, "err"


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def send_json(self, obj, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.end_headers()
        self.wfile.write(json.dumps(obj, ensure_ascii=False).encode("utf-8"))

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/") or "/"
        if path == "/" or path == "/index.html":
            self.serve_index()
        elif path == "/api/status":
            ok, out, err = run_ctl(["status"])
            self.send_json({"bypass": out == "enabled", "raw": out, "error": err if not ok else None})
        elif path == "/api/enable":
            ok, out, err = run_ctl(["enable"])
            self.send_json({"ok": ok, "message": out or err})
        elif path == "/api/disable":
            ok, out, err = run_ctl(["disable"])
            self.send_json({"ok": ok, "message": out or err})
        elif path == "/api/test-google":
            ok, code = test_google()
            self.send_json({"ok": ok, "code": code})
        elif path == "/api/shutdown":
            ok, _, err = run_power("shutdown")
            self.send_json({"ok": ok, "message": err or ("已发送关机" if ok else "失败")})
        elif path == "/api/reboot":
            ok, _, err = run_power("reboot")
            self.send_json({"ok": ok, "message": err or ("已发送重启" if ok else "失败")})
        else:
            self.send_error(404)

    def serve_index(self):
        p = os.path.join(os.path.dirname(__file__), "index.html")
        try:
            with open(p, "rb") as f:
                body = f.read()
        except FileNotFoundError:
            self.send_error(404)
            return
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main():
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    server.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    print("Bypass config: http://<pi-ip>:%s" % PORT)
    server.serve_forever()


if __name__ == "__main__":
    main()
