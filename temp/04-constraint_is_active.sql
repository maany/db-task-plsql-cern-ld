create or replace view settings_is_valid_counts as
select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as no_active_settings
from settings
where IS_ACTIVE = 'Y'
group by (PARAMETER_ID, PROCESS_ID)
/

select * from settings_is_valid_counts
/

drop view settings_is_valid_counts;
/

select count(active_setting_count) as violations_count
from (select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as active_setting_count
      from settings
      where IS_ACTIVE = 'Y'
      group by (PARAMETER_ID, PROCESS_ID))
where active_setting_count > 1
/


create or replace trigger pre_settings_update_trigg
    before insert or update
    on settings
    for each row
declare
    l_violations_count number;
begin
--     select count(active_setting_count) into l_violations_count
--     from (select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as active_setting_count
--           from settings
--           where :new.IS_ACTIVE = 'Y'
--           group by (PARAMETER_ID, PROCESS_ID))
--     where active_setting_count > 1;
--     select no_active_settings into l_violations_count from settings_is_valid_counts;
    sys.dbms_output.PUT_LINE('For this row, we get');

--     if l_violations_count > 0 then
--         raise_application_error(-20010, 'Man, this works');
--     end if;

end;
/

drop trigger pre_settings_update_trigg;
/

SELECT * FROM (
            SELECT t.*
            FROM DELPHI.SETTINGS t
            ORDER BY SETTING_ID
        ) WHERE ROWNUM <= 501
/
select * from settings