"""Product Service - minimal Python HTTP server for EKS demo."""
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

PORT = int(os.environ.get("PORT", "8080"))
APP_NAME = os.environ.get("APP_NAME", "product-service")
ENV = os.environ.get("ENV", "dev")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({
            "service": APP_NAME,
            "env": ENV,
            "path": self.path,
            "message": "Product service is running"
        }).encode())

if __name__ == "__main__":
    server = HTTPServer(("", PORT), Handler)
    print(f"Serving {APP_NAME} on port {PORT}")
    server.serve_forever()
