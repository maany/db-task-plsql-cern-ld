create or replace trigger check_active_settings_before_new_settings
    before insert or update
    on settings
    for each row
declare
    l_log_message varchar(256);
    l_active_setting_id number; --settings.setting_id%type;
    cursor cur_active_settings_per_param_process is
        select * from ACTIVE_SETTING_PER_PARAM_PROCESS where PARAMETER_ID=:new.parameter_id
                                                         and process_id = :new.process_id;
    l_cur_row cur_active_settings_per_param_process%ROWTYPE;
begin
    l_log_message := 'Trigger: [ parameter_id: ' || :new.parameter_id || ', process_id:' || :new.process_id || ']';
    open cur_active_settings_per_param_process;
--     loop
--         fetch cur_active_settings_per_param_process into l_cur_row;
--         exit when cur_active_settings_per_param_process%NOTFOUND;
--         dbms_output.put_line(l_log_message || ' active setting is: ' || l_cur_row.current_active_setting_id);
--     end loop;
--     dbms_output.put_line(l_log_message || ' total rows parsed: ' || cur_active_settings_per_param_process%ROWCOUNT);
--
    close cur_active_settings_per_param_process;

--     l_active_setting_id := task4.GET_ACTIVE_SETTING(:new.PARAMETER_ID, :new.SETTING_ID);
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
update settings set is_active = 'Y' where parameter_id = 1 and process_id = 1;
update settings set is_active = 'Y' where setting_id = 1;

/
create unique index enforce_one_is_valid on settings (parameter_id, process_id, nullif(is_active, 'N'));
/
drop index enforce_one_is_valid;
