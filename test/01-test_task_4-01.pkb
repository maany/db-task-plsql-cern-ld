create or replace package body test_task_4 as
    -- test that only one setting per process/parameter combo can be is_valid = 'Y'
    function util_get_active_setting(
        i_parameter_id number,
        i_process_id number
    ) return number
        is
        l_active_setting_count number; -- settings.is_valid%type;
    begin
        select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as no_active_settings
        from settings
        where IS_ACTIVE = 'Y'
          and PARAMETER_ID = 2
          and PROCESS_ID = 2
        group by (PARAMETER_ID, PROCESS_ID);
        if SQL%FOUND then
            l_active_setting_count := SQL%ROWCOUNT;
        end if;
    end util_get_active_setting;

end test_task_4;
/
begin
    test_task_4.util
end;
/
select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as no_active_settings
from settings
where IS_ACTIVE = 'Y'
  and PARAMETER_ID = 2
  and PROCESS_ID = 2
group by (PARAMETER_ID, PROCESS_ID)
/
