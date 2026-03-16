"""User Service - minimal Python HTTP server for EKS demo."""
# user_service/app.py
from flask import Flask, jsonify

app = Flask(__name__)

users = [
    {"id": 1, "name": "Manoj", "email": "manoj@test.com"},
    {"id": 2, "name": "DevOps User", "email": "devops@test.com"}
]

@app.route("/users")
def get_users():
    return jsonify(users)

@app.route("/users/<int:uid>")
def get_user(uid):
    user = next((u for u in users if u["id"] == uid), None)
    if user:
        return jsonify(user)
    return jsonify({"error": "User not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
