create or replace view active_setting_per_param_process as
select PARAMETER_ID,
       PROCESS_ID,
       max(setting_id)     as current_active_setting_id,
       count(PARAMETER_ID) as total_active_settings
from settings
where IS_ACTIVE = 'Y'
group by (PARAMETER_ID, PROCESS_ID)

-- create a index on (parameter_id, process_id, {is_active setting}).
-- make it unique to ensure if another setting tries for same parameter_id, process_id tries to set 'is_active' = 'Y',
-- the index should not allow it.
create unique index enforce_one_is_active on settings (parameter_id, process_id, nullif(is_active, 'N'));