{{ config(materialized='view') }}

-- Remove rows that are identical in every selected column
with distinct_records as (

    select distinct *
    from {{ ref('silver_orders_file') }}

),

-- Count how many different records share an order ID
counted_records as (

    select
        *,
        count(*) over (
            partition by order_id
        ) as records_for_order_id

    from distinct_records

)

-- Label each record as valid or explain its first problem
select
    *,

    case
        when order_id is null or order_id <= 0
            then 'Invalid order ID'

        when customer_id is null or customer_id <= 0
            then 'Invalid customer ID'

        when order_date is null
            then 'Invalid order date'

        when status is null
            or status not in (
                'completed',
                'pending',
                'cancelled'
            )
            then 'Invalid status'

        when amount is null or amount < 0
            then 'Invalid amount'

        when records_for_order_id > 1
            then 'Conflicting order ID'

        else 'Valid'
    end as quality_result

from counted_records 