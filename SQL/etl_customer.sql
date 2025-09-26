--------- Increamentally load new customers into staging ----------

insert into wh_stage.stg_customer(customer_id , country , etl_insert_ts , etl_update_ts)
select distinct
customerid :: varchar(20),
country,
now() as etl_insert_ts,
now() as etl_update_ts
from wh_source.online_retail_raw orw
where customerid is not null
and not exists (
select 1 from wh_stage.stg_customer t
where t.customer_id = orw.customerid :: varchar(20)
)
on conflict (customer_id) do nothing;

-------- Incrementally load new customers into core dimension table.-------

insert into wh_core.dim_customer(customer_id , country ,start_date , end_date , current_flag)
select
sc.customer_id,
sc.country,
now() as start_date,
null as end_date,
true as current_flag
from wh_stage.stg_customer sc
where not exists (
select 1 from wh_core.dim_customer dc
where dc.customer_id = sc.customer_id
and dc.current_flag = true
);