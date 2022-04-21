select 
    id as consumer_lead_id,
    email,
    created_at
from {{ source('happity', 'consumer_leads') }}