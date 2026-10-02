{{ config(materialized='table') }}

-- One summary row per customer
select
    customer_id,

    count(*) as total_orders,

    count_if(status = 'completed') as completed_orders,

    count_if(status = 'pending') as pending_orders,

    count_if(status = 'cancelled') as cancelled_orders,

    sum(amount) as total_order_amount,

    sum(
        case
            when status = 'completed' then amount
            else 0
        end
    ) as completed_order_amount,

    min(order_date) as first_order_date,

    max(order_date) as latest_order_date

from {{ ref('silver_orders') }}

group by customer_id