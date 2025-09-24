----------- Create Schemas -------------------

create schema wh_source;
create schema wh_stage;
create schema wh_core;
create schema wh_reports;

drop schema WH_SOURCE cascade;
drop schema WH_STAGE cascade;
drop schema WH_CORE cascade;
drop schema WH_REPORTS cascade;

-----------------------------------------------

----------- Create Source Table ---------------

create table wh_source.online_retail_raw(
invoiceno varchar(20),
stockcode varchar(20),
description text,
quantity integer,
invoicedate timestamp,
unitprice numeric(10,2),
customerid varchar(30),
country varchar(50)
);

drop table WH_SOURCE.onnlie_retail_raw;
select * from wh_source.online_retail_raw;
truncate table wh_source.online_retail_raw;

---------------------------------------------------

------------ Copy from local to postgresql ---------

copy wh_source.online_retail_raw (invoiceno , stockcode , description , quantity , invoicedate , unitprice , customerid , country)
from 'D:\projects\Data_warehousing\Data\raw_data.csv'
delimiter ','
csv header;

------------------------------------------------------

------------- wh_stage tables -----------------------

create table wh_stage.stg_customer(
customer_id varchar(20) primary key,
country varchar(50),
etl_insert_ts timestamp default current_timestamp,
etl_update_ts timestamp default current_timestamp
);

select * from wh_stage.stg_customer;

create table wh_stage.stg_product(
stock_code varchar(20) primary key,
description text,
etl_insert_ts timestamp default current_timestamp,
etl_update_ts timestamp default current_timestamp
);

create table wh_stage.stg_fact_sales(
invoice_no varchar(20),
stock_code varchar(20),
customer_id varchar(20),
quantity integer,
unit_price numeric(10,2),
etl_insert_ts timestamp default current_timestamp,
etl_update_ts timestamp default current_timestamp
);

------------------------------------------------------

---------------- wh_core tables ----------------------

create table wh_core.dim_customer(
customer_key serial primary key,
customer_id varchar(20) unique,
country varchar(50),
start_date timestamp default current_timestamp,
end_date timestamp,
current_flag boolean default true 
);

create table wh_core.dim_product(
product_key serial primary key,
stock_code varchar(20) unique,
description text,
start_date timestamp default current_timestamp,
end_date timestamp,
current_flag boolean default true
);

create table wh_core.dim_date(
date_key date primary key,
day int,
month int,
year int,
day_of_week varchar(15),
is_weekend boolean
);

create table wh_core.fact_sales(
sales_key serial primary key,
invoice_no varchar(20),
customer_key int references wh_core.dim_customer(customer_key),
product_ket int references wh_core.dim_product(product_key),
quantity integer,
unit_price numeric(10,2),
total_amount numeric(14,2),
country varchar(50)
);

ALTER TABLE wh_core.fact_sales
ADD COLUMN invoice_date DATE;
select * from wh_core.fact_sales;

-----------------------------------------------------