create or replace view active_setting_per_param_process as
select PARAMETER_ID,
       PROCESS_ID,
       max(setting_id)     as current_active_setting_id,
       count(PARAMETER_ID) as total_active_settings
from settings
where IS_ACTIVE = 'Y'
group by (PARAMETER_ID, PROCESS_ID)
/