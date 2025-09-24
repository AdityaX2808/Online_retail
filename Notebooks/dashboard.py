import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import urllib

# Database credentials and config
DB_USER = ''
DB_PASS = urllib.parse.quote_plus('')
DB_HOST = 'localhost'
DB_PORT = '5432'
DB_NAME = ''

# Create SQLAlchemy engine with search_path set to 'wh_reports' schema
engine = create_engine(
    f'postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}',
    connect_args={'options': '-csearch_path=wh_reports,public'}
)

def run_query(query):
    with engine.connect() as conn:
        return pd.read_sql_query(query, conn)

st.set_page_config(page_title="Retail Sales Dashboard", layout="wide")
st.title("Retail Sales Dashboard")

# Create three columns side by side
col1, col2, col3 = st.columns(3)

with col1:
    st.subheader("Top 10 Customers by Sales")
    try:
        df_top_customers = run_query("SELECT * FROM wh_reports.top_customers;")
        if not df_top_customers.empty:
            df_top_customers.set_index('customer_id', inplace=True)
            st.bar_chart(df_top_customers['total_sales'])
        else:
            st.info("No data available for Top Customers.")
    except Exception as e:
        st.error(f"Failed to load Top Customers data: {str(e)}")

with col2:
    st.subheader("Sales By Region")
    try:
        df_sales_by_region = run_query("SELECT * FROM wh_reports.sales_by_region;")
        if not df_sales_by_region.empty:
            df_sales_by_region.set_index('region', inplace=True)
            st.bar_chart(df_sales_by_region['total_sales'])
        else:
            st.info("No data available for Sales by Region.")
    except Exception as e:
        st.error(f"Failed to load Sales by Region data: {str(e)}")

with col3:
    st.subheader("Product Category Performance")
    try:
        df_product_category = run_query("SELECT * FROM wh_reports.product_category_performance;")
        if not df_product_category.empty:
            # Adjust index based on available columns
            if 'category' in df_product_category.columns:
                df_product_category.set_index('category', inplace=True)
            else:
                df_product_category.set_index('stock_code', inplace=True)
            st.bar_chart(df_product_category['total_sales'])
        else:
            st.info("No data available for Product Category Performance.")
    except Exception as e:
        st.error(f"Failed to load Product Category Performance data: {str(e)}")

st.markdown("---")
st.caption("Dashboard powered by Streamlit and PostgreSQL")
