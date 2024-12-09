from flask import Flask, request
import psycopg2
import os

app = Flask(__name__)

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'default_db')
DB_USER = os.getenv('DB_USER', 'default_user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'default_password')

def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    return conn

@app.route("/reversed-ip")
def index():
    ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    reversed_ip = ip[::-1]

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO ips (ip_address, reversed_ip) VALUES (%s, %s) RETURNING id", (ip, reversed_ip))
        last_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        return f"Error saving IP: {str(e)}"

    return (
        f"IP: {ip}, Reverse: {reversed_ip}<br>"
        f"Status: Both values saved in the database successfully!<br>"
        f"Last record: {last_id}<br>"
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)