create or replace trigger check_active_settings_before_new_settings
    before update
    on settings
    for each row
declare
    l_log_message varchar(256);
    l_active_setting_id number; --settings.setting_id%type;
begin
    l_log_message := 'Trigger: [ parameter_id: ' || :new.parameter_id || ', process_id:' || :new.process_id || ']';
    dbms_output.put_line(l_log_message);
    l_active_setting_id := task4.GET_ACTIVE_SETTING(:new.PARAMETER_ID, :new.SETTING_ID);
--     if l_active_setting_id = :new.setting_id then
--         raise_application_error( -20202, 'Setting ' || l_active_setting_id  || ' is already active for ' || l_log_message);
--     end if;
-- exception
--     when task4.no_active_setting then
--         raise_application_error( -20201,'No record found for ' || l_log_message);
end;
/
select * from settings;
select * from ACTIVE_SETTING_PER_PARAM_PROCESS;
/
update settings set is_active = 'N' where parameter_id = 1 and process_id = 1;