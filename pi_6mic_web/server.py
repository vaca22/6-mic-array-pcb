#!/usr/bin/env python3
"""
6-mic real-time waveform server. Streams PCM via SSE; serves a single HTML page.
Uses only stdlib + arecord subprocess. Run on Raspberry Pi.
"""
import subprocess
import threading
import base64
import time
import os
import socket
from http.server import HTTPServer, BaseHTTPRequestHandler

# 6ch, S32_LE, 16kHz. Chunk = 512 frames (~32ms)
RATE = 16000
CHANNELS = 6
CHUNK_FRAMES = 512
BYTES_PER_SAMPLE = 4
CHUNK_BYTES = CHUNK_FRAMES * CHANNELS * BYTES_PER_SAMPLE

# Last chunk for SSE (single consumer for simplicity)
latest_chunk = None
latest_lock = threading.Lock()

def capture_worker():
    """Run arecord and push raw PCM chunks into global latest_chunk."""
    global latest_chunk
    cmd = [
        "arecord", "-D", "plughw:seeed8micvoicec,0",
        "-f", "S32_LE", "-r", str(RATE), "-c", str(CHANNELS),
        "-t", "raw", "-q"
    ]
    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        while True:
            raw = proc.stdout.read(CHUNK_BYTES)
            if len(raw) < CHUNK_BYTES:
                break
            with latest_lock:
                latest_chunk = raw
    except Exception:
        pass
    finally:
        try:
            proc.terminate()
        except Exception:
            pass


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            self.serve_index()
        elif self.path == "/stream":
            self.serve_stream()
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

    def serve_stream(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        try:
            while True:
                with latest_lock:
                    chunk = latest_chunk
                if chunk:
                    b64 = base64.b64encode(chunk).decode("ascii")
                    self.wfile.write(b"data: " + b64.encode() + b"\n\n")
                time.sleep(0.02)  # ~50 FPS max
        except (BrokenPipeError, ConnectionResetError):
            pass


def main():
    t = threading.Thread(target=capture_worker, daemon=True)
    t.start()
    time.sleep(0.5)
    port = 8080
    server = HTTPServer(("0.0.0.0", port), Handler)
    server.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    print("6-mic waveform: http://<pi-ip>:%s" % port)
    server.serve_forever()


if __name__ == "__main__":
    main()
