"""API Gateway - minimal Python HTTP server for EKS demo."""
# api_gateway/app.py
from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

PRODUCT_SERVICE = "http://product-service:80"
USER_SERVICE = "http://user-service:80"

@app.route("/")
def home():
    return jsonify({"service": "api-gateway", "status": "running"})

@app.route("/products")
def products():
    r = requests.get(f"{PRODUCT_SERVICE}/products")
    return jsonify(r.json())

@app.route("/users")
def users():
    r = requests.get(f"{USER_SERVICE}/users")
    return jsonify(r.json())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
