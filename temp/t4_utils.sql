create or replace trigger settings_changed_trigger
    after insert or update
    on settings
    for each row
declare
    l_log_message varchar(256);
begin
    l_log_message := '( '  || :new.parameter_id || ', ' || :new.process_id || ')';
    dbms_output.PUT_LINE('Analysing insert for ' || l_log_message);
    activate_setting(
        :new.PARAMETER_ID,
        :new.PROCESS_ID,
        :new.SETTING_ID,
        :new.IS_ACTIVE);
exception
    when VALUE_ERROR then
        update settings set is_active = 'N' where SETTING_ID = 5;
end;
/

/
select * from settings;
/
select * from SETTINGS_CACHE;
/
update settings set IS_ACTIVE = 'Y' where SETTING_ID = 3;
/

create or replace trigger check_active_settings_before_new_settings
    after insert or update
    on settings
    for each row
declare
    l_log_message       varchar(256);
    l_active_setting_id number; --settings.setting_id%type;
--     cursor cur_active_settings_per_param_process is
--         select * from ACTIVE_SETTING_PER_PARAM_PROCESS where PARAMETER_ID=:new.parameter_id
--                                                          and process_id = :new.process_id;
--     l_cur_row cur_active_settings_per_param_process%ROWTYPE;
begin
    l_log_message := 'Trigger: [ parameter_id: ' || :new.parameter_id || ', process_id:' || :new.process_id || ']';
    if inserting then
        dbms_output.put_line('Interting into settings_cache');
        if :new.is_active = 'Y' then
        insert into settings_cache (parameter_id, process_id, active_setting_id)
        values (:new.parameter_id, :new.process_id, :new.setting_id);
        end if;
    end if;
    --     open cur_active_settings_per_param_process;
--     loop
--         fetch cur_active_settings_per_param_process into l_cur_row;
--         exit when cur_active_settings_per_param_process%NOTFOUND;
--         dbms_output.put_line(l_log_message || ' active setting is: ' || l_cur_row.current_active_setting_id);
--     end loop;
--     dbms_output.put_line(l_log_message || ' total rows parsed: ' || cur_active_settings_per_param_process%ROWCOUNT);
--
--     close cur_active_settings_per_param_process;

--     l_active_setting_id := task4.GET_ACTIVE_SETTING(:new.PARAMETER_ID, :new.SETTING_ID);
--     if l_active_setting_id = :new.setting_id then
--         raise_application_error( -20202, 'Setting ' || l_active_setting_id  || ' is already active for ' || l_log_message);
--     end if;
-- exception
--     when task4.no_active_setting then
--         raise_application_error( -20201,'No record found for ' || l_log_message);
end;
/