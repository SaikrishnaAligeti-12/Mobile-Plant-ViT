from flask import Blueprint, request, jsonify, send_from_directory
from db_config import get_db_connection
from datetime import datetime
import os

history_bp = Blueprint('history_bp', __name__)
UPLOAD_FOLDER = "uploads"

# 📥 Add a new scan history record
@history_bp.route('/history/add', methods=['POST'])
def add_history():
    user_id = request.form['user_id']
    image = request.files['image']
    plant_name = request.form['plant_name']
    disease_name = request.form['disease_name']
    confidence = request.form['confidence']

    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    filename = f"user_{user_id}_{timestamp}.jpg"
    image.save(os.path.join(UPLOAD_FOLDER, filename))

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO history (user_id, image_path, plant_name, disease_name, confidence) VALUES (%s, %s, %s, %s, %s)",
        (user_id, filename, plant_name, disease_name, confidence)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "History saved successfully"}), 201


# 📤 Get user’s history
@history_bp.route('/history/<int:user_id>', methods=['GET'])
def get_history(user_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # ✅ Only select required columns
    cursor.execute("""
        SELECT image_path, plant_name, disease_name 
        FROM history 
        WHERE user_id = %s 
        ORDER BY created_at DESC
    """, (user_id,))
    
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(rows), 200



# 🖼️ Serve saved images
@history_bp.route('/history/image/<filename>')
def get_image(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)
