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

create or replace trigger settings_changed_trigger
    after insert or update
    on settings
declare
    l_log_message varchar(256);
begin
    for result in (select setting_id, parameter_id, process_id, is_active from settings)
        loop
            l_log_message := '( '  || result.parameter_id || ', ' || result.process_id || ')';
            dbms_output.PUT_LINE('Analysing insert for ' || l_log_message);
            activate_setting(
                result.PARAMETER_ID,
                result.PROCESS_ID,
                result.SETTING_ID,
                result.IS_ACTIVE);
        end loop;
end;




/
select * from settings;
/
select * from SETTINGS_CACHE;
/
update settings set IS_ACTIVE = 'Y' where SETTING_ID = 5;
/