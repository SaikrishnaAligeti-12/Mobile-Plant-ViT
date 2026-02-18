import mysql.connector

def get_db_connection():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="    ",  # your password
        database="plant_disease_app"
    )
    return connection
