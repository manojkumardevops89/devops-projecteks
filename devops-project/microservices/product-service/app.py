"""Product Service - minimal Python HTTP server for EKS demo."""
# product_service/app.py
from flask import Flask, jsonify

app = Flask(__name__)

products = [
    {"id": 1, "name": "Laptop", "price": 800},
    {"id": 2, "name": "Mobile", "price": 400},
    {"id": 3, "name": "Headphones", "price": 100}
]

@app.route("/products")
def get_products():
    return jsonify(products)

@app.route("/products/<int:pid>")
def get_product(pid):
    product = next((p for p in products if p["id"] == pid), None)
    if product:
        return jsonify(product)
    return jsonify({"error": "Product not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
