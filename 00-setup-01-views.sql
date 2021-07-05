create or replace view active_setting_per_param_process as
select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as no_active_settings
from settings
where IS_ACTIVE = 'Y'
group by (PARAMETER_ID, PROCESS_ID)
/
drop view settings_is_valid_counts;