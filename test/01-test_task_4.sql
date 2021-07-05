declare
    l_parameter_id        number;
    l_process_id          number;
    l_inactive_setting_id number;
    l_active_setting_id   number;
    l_result              number;
begin
    dbms_output.PUT_LINE('Testing Task 4');
    select PARAMETER_ID, PROCESS_ID
    into l_parameter_id, l_process_id
    from ACTIVE_SETTING_PER_PARAM_PROCESS
    where NO_ACTIVE_SETTINGS > 0 fetch first 1 rows only;

    select setting_id
    into l_inactive_setting_id
    from settings
    where PARAMETER_ID = l_parameter_id
      and PROCESS_ID = l_process_id
      and IS_ACTIVE = 'N' FETCH first 1 rows only;
    dbms_output.PUT_LINE(
                'Parameter ID: ' || l_parameter_id || ', Process_ID: ' || l_process_id || ', Inactive Setting: ' ||
                l_inactive_setting_id);

    select setting_id
    into l_active_setting_id
    from settings
    where PARAMETER_ID = l_parameter_id
      and PROCESS_ID = l_process_id
      and IS_ACTIVE = 'Y' FETCH first 1 rows only;
    dbms_output.PUT_LINE(
                'Parameter ID: ' || l_parameter_id || ', Process_ID: ' || l_process_id || ', Active Setting: ' ||
                l_active_setting_id);

    dbms_output.PUT_LINE('Make active setting inactive');
    update settings set IS_ACTIVE = 'N' where SETTING_ID = l_active_setting_id;

    dbms_output.PUT_LINE('Reactivate old active setting');
    update settings set IS_ACTIVE = 'Y' where SETTING_ID = l_active_setting_id;

end;
/

select * from settings;
select * from settings_cache;
/
update settings set IS_ACTIVE = 'Y' where setting_id = 9; -- where PARAMETER_ID=1 and process_id=1 and IS_ACTIVE = 'Y';
insert into settings (PARAMETER_ID, PROCESS_ID, IS_ACTIVE, VALUE_TYPE) values (3, 2, 'Y', 'INT');
delete from settings where SETTING_ID = 9;
insert into SETTINGS_CACHE (parameter_id, process_id, active_setting_id) values(3, 2, null);
update SETTINGS_CACHE set ACTIVE_SETTING_ID = 12 where ACTIVE_SETTING_ID = 12;