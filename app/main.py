"""Tiny whoami service: reports which container/host answered the request."""
import os
import platform
import socket
import time

from flask import Flask, jsonify, request

START_TIME = time.time()
app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        service="whoami",
        version=os.getenv("APP_VERSION", "dev"),
        hostname=socket.gethostname(),
        python=platform.python_version(),
        client_ip=request.headers.get("X-Forwarded-For", request.remote_addr),
        user_agent=request.headers.get("User-Agent", ""),
        uptime_seconds=round(time.time() - START_TIME, 1),
    )


@app.get("/health")
def health():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
