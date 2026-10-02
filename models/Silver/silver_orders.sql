{{ config(materialized='table') }}

-- Keep only valid orders
select
    order_id,
    customer_id,
    order_date,
    status,
    amount

from {{ ref('orders_checked') }}

where quality_result = 'Valid'