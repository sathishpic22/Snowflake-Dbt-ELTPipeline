/*
Order ID: Remove surrounding spaces, check that it contains only digits, and convert it to a whole number; invalid values become NULL.
Customer ID: Apply the same cleaning to customer IDs; missing values, letters, and negative IDs become NULL.
Order date: Convert YYYY-MM-DD or MM/DD/YYYY text into a date; missing or impossible dates become NULL.
Status: Remove surrounding spaces, convert to lowercase, change complete to completed, and turn empty values into NULL.
Amount: Remove surrounding spaces and thousands commas, then convert to a number with two decimal places; invalid values become NULL, while negative numbers remain for later validation.
 */
{{ config(materialized="view") }}

select
    to_varchar(order_id) as raw_order_id,
    to_varchar(customer_id) as raw_customer_id,
    to_varchar(order_date) as raw_order_date,
    to_varchar(status) as raw_status,
    to_varchar(amount) as raw_amount,

    case
        when regexp_like(trim(to_varchar(order_id)), '^[0-9]+$')
        then try_to_number(trim(to_varchar(order_id)), 38, 0)
    end as order_id,

    case
        when regexp_like(trim(to_varchar(customer_id)), '^[0-9]+$')
        then try_to_number(trim(to_varchar(customer_id)), 38, 0)
    end as customer_id,

    coalesce(
        try_to_date(trim(to_varchar(order_date)), 'YYYY-MM-DD'),
        try_to_date(trim(to_varchar(order_date)), 'MM/DD/YYYY')
    ) as order_date,

    case
        when lower(trim(to_varchar(status))) = 'complete'
        then 'completed'
        else nullif(lower(trim(to_varchar(status))), '')
    end as status,

    try_to_decimal(replace(trim(to_varchar(amount)), ',', ''), 18, 2) as amount

from {{ source("orders_raw", "orders") }}
