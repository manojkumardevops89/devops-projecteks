"""API Gateway - minimal Python HTTP server for EKS demo."""
from flask import Flask, jsonify
import requests

app = Flask(__name__)
PRODUCT_SERVICE = "http://product-service:80"
USER_SERVICE = "http://user-service:80"

HTML = open("index.html").read()

@app.route("/")
def home():
    return jsonify({"service": "api-gateway", "status": "running"})

@app.route("/ui")
def ui():
    return HTML

@app.route("/products")
def products():
    r = requests.get(PRODUCT_SERVICE + "/products")
    return jsonify(r.json())

@app.route("/users")
def users():
    r = requests.get(USER_SERVICE + "/users")
    return jsonify(r.json())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
