with invoices as (select * from {{ source('stripe', 'invoices') }})
select 
    id as stripe_invoice_id, 
    customer as stripe_customer_id,
    total,
    tax,
    status,
    amount_due,
    amount_paid,
    timestamp_seconds(cast (period_start as int64)) as period_start_ts,
    timestamp_seconds(cast (period_end as int64)) as period_end_ts,
    timestamp_seconds(cast (created as int64)) as created_ts
    
from invoices a
where not exists (
  -- we will get duplicate rows for invoices, and we should only look at the most recent. Probably a good idea to trim the table down periodically,
  -- either by resetting data from Airbyte, or running a delete with a query like this one
  Select 1 from invoices b where a.id = b.id and b._airbyte_emitted_at > a._airbyte_emitted_at
)