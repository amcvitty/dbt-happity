-- we have a companies_scd table, but really the latest name is fine
select 
    id as company_id, 
    name 
from {{ source('happity', 'companies') }}
