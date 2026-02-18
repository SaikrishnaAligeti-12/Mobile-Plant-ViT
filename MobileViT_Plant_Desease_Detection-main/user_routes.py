from flask import Blueprint, request, jsonify
from db_config import get_db_connection
import bcrypt

user_bp = Blueprint('user_bp', __name__)

# 🧾 Register new user
@user_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    name = data['name']
    age = data['age']
    gender = data['gender']
    username = data['username']
    email = data['email']
    password = data['password'].encode('utf-8')
    hashed_pw = bcrypt.hashpw(password, bcrypt.gensalt())

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            "INSERT INTO users (name, age, gender, username, email, password) VALUES (%s,%s,%s,%s,%s,%s)",
            (name, age, gender, username, email, hashed_pw)
        )
        conn.commit()
        return jsonify({"message": "User registered successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        cursor.close()
        conn.close()


# 🔐 Login
@user_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username_or_email = data['username']
    password = data['password'].encode('utf-8')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username=%s OR email=%s", (username_or_email, username_or_email))
    user = cursor.fetchone()

    if user and bcrypt.checkpw(password, user['password'].encode('utf-8')):
        del user['password']
        return jsonify({"message": "Login successful", "user": user}), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401


# 🧍 Update profile
@user_bp.route('/update_profile', methods=['PUT'])
def update_profile():
    data = request.get_json()
    user_id = data['id']
    name = data.get('name')
    age = data.get('age')
    gender = data.get('gender')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor()

    if password:
        hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        cursor.execute("UPDATE users SET name=%s, age=%s, gender=%s, password=%s WHERE id=%s",
                       (name, age, gender, hashed_pw, user_id))
    else:
        cursor.execute("UPDATE users SET name=%s, age=%s, gender=%s WHERE id=%s",
                       (name, age, gender, user_id))

    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "Profile updated successfully"}), 200
