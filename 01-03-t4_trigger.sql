create or replace trigger settings_changed_trigger
    after insert or update
    on settings
declare
    l_log_message varchar(256);
begin
    for result in (select setting_id, parameter_id, process_id, is_active from settings)
        loop
            l_log_message := '( ' || result.parameter_id || ', ' || result.process_id || ')';
            dbms_output.PUT_LINE('Analysing trigger for (parameter_id, process_id): ' || l_log_message);
            DB_TASK_ADD_ONS.activate_setting(
                    result.PARAMETER_ID,
                    result.PROCESS_ID,
                    result.SETTING_ID,
                    result.IS_ACTIVE);
        end loop;
end;
