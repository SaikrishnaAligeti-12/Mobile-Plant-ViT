from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import bcrypt
import os
from datetime import datetime
from user_routes import user_bp
from history_routes import history_bp
from model_logic import (
    predict_disease,
    load_vit_model,
    load_efficientnet_model
)

# ===============================
# Initialize Flask
# ===============================
app = Flask(__name__)
CORS(app)

# ===============================
# MySQL Configuration
# ===============================
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Varun@6688',
    'database': 'plant_disease_app'
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

# ===============================
# Upload Folder
# ===============================
UPLOAD_FOLDER = "static/uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# ===============================
# Load Both Models
# ===============================
print("🧠 Loading models...")
vit_model = load_vit_model("plant_vit_model.pth")

try:
    eff_model = load_efficientnet_model("efficientnetv2_ccmt_best.pth")
    print("✅ Both models loaded successfully!")
except Exception as e:
    eff_model = None
    print(f"⚠️ Model 2 (EfficientNetV2) not available yet: {e}")

# ===============================
# Routes
# ===============================
@app.route('/')
def home():
    return "🌿 Plant Disease Detection API is running!"

# 🧾 Signup
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    username = data['username']
    email = data['email']
    password = data['password'].encode('utf-8')
    name = data.get('name')
    age = data.get('age')
    gender = data.get('gender')

    hashed = bcrypt.hashpw(password, bcrypt.gensalt())

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (username,email,password,name,age,gender) VALUES (%s,%s,%s,%s,%s,%s)",
            (username, email, hashed.decode('utf-8'), name, age, gender)
        )
        conn.commit()
        return jsonify({"message": "User created successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        cursor.close()
        conn.close()

# 🔐 Login
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data['email']
    password = data['password'].encode('utf-8')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if user and bcrypt.checkpw(password, user['password'].encode('utf-8')):
        return jsonify({
            "message": "Login successful",
            "user_id": user['id'],
            "username": user['username'],
            "name": user.get('name', '')
        })
    else:
        return jsonify({"error": "Invalid credentials"}), 401

# 🌿 Predict Disease
@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files or 'user_id' not in request.form:
        return jsonify({"error": "Missing image or user_id"}), 400

    image = request.files['image']
    user_id = request.form['user_id']
    model_type = request.form.get('model_type', 'vit')  # 'vit' or 'efficientnet'

    # Save image
    image_path = os.path.join(UPLOAD_FOLDER, image.filename)
    image.save(image_path)

    # Load image bytes
    with open(image_path, 'rb') as f:
        image_bytes = f.read()

    # Choose model
    if model_type == 'efficientnet':
        if eff_model is None:
            return jsonify({"error": "Model 2 not yet trained"}), 400
        result = predict_disease(image_bytes, eff_model)
    else:
        result = predict_disease(image_bytes, vit_model)

    # Save to DB
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO scan_history (user_id, image_path, plant_name, disease_name, confidence, scanned_at) VALUES (%s,%s,%s,%s,%s,%s)",
        (user_id, image_path, result['plant_name'], result['disease_name'], result['confidence'], datetime.now())
    )
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify(result)

# 📜 History
@app.route('/history/<int:user_id>', methods=['GET'])
def history(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM scan_history WHERE user_id=%s ORDER BY scanned_at DESC", (user_id,))
    records = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(records)

# 🧍 Update profile
@app.route('/update_profile/<int:user_id>', methods=['PUT'])
def update_profile(user_id):
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET name=%s, age=%s, gender=%s WHERE id=%s",
                   (data.get('name'), data.get('age'), data.get('gender'), user_id))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "Profile updated"})

# 🔑 Change password
@app.route('/change_password/<int:user_id>', methods=['PUT'])
def change_password(user_id):
    data = request.json
    new_pass = data['new_password'].encode('utf-8')
    hashed = bcrypt.hashpw(new_pass, bcrypt.gensalt())
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET password=%s WHERE id=%s", (hashed.decode('utf-8'), user_id))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "Password changed successfully"})

# ✅ Register Blueprints
app.register_blueprint(user_bp)
app.register_blueprint(history_bp)

# ===============================
# Run Server
# ===============================
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
