select 
    id as user_id,
    email,
    role,
    created_at,
    _airbyte_start_at as scd_start_at,
    _airbyte_end_at as scd_end_at
from {{ source('happity', 'users_scd') }}