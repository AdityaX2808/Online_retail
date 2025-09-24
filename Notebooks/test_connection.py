import psycopg2
from psycopg2 import OperationalError

try:
    conn = psycopg2.connect(
        host="localhost",
        database="",
        user="postgres",
        password="",
        port="5432"
    )
    print("Connection successful")
    conn.close()
except OperationalError as e:
    print(f"Connection failed: {e}")
