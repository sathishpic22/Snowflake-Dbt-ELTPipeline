{{ config(materialized='table') }}

-- Summarize clean orders by date
select
    order_date,

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
    ) as completed_order_amount

from {{ ref('silver_orders') }}

group by order_date