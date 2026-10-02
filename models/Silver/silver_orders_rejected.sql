{{ config(materialized='table') }}

-- Save problem records with their original values and reason
select *
from {{ ref('orders_checked') }}
where quality_result <> 'Valid'