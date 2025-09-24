from sqlalchemy import create_engine, text
import urllib

DB_USER = ''
DB_PASS = urllib.parse.quote_plus('')
DB_HOST = 'localhost'
DB_PORT = '5432'
DB_NAME = ''

engine = create_engine(
    f'postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}',
    connect_args={'options': '-csearch_path=wh_reports,public'}
)

with engine.connect() as conn:
    version = conn.execute(text("SELECT version();")).scalar()
    user = conn.execute(text("SELECT current_user;")).scalar()
    schema_exists = conn.execute(text(
        "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'wh_reports';"
    )).fetchone()
    views_exist = conn.execute(text(
        "SELECT table_name FROM information_schema.views WHERE table_schema = 'wh_reports';"
    )).fetchall()

print("PostgreSQL Version:", version)
print("Connected User:", user)
print("Schema 'wh_reports' exists:", schema_exists is not None)
print("Views in 'wh_reports' schema:", [v[0] for v in views_exist])
