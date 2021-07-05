create or replace trigger settings_changed_trigger
    before insert or update
    on settings
    for each row
declare
    l_log_header varchar2(250);
begin
    l_log_header := '( '  || :new.parameter_id || ', ' || :new.process_id || ')';
    dbms_output.put_line('Analyzing ' || l_log_header);
    update_settings_cache(
          :new.PARAMETER_ID, :new.PROCESS_ID, :new.IS_ACTIVE
    );
exception
    when NO_DATA_FOUND then

--     insert into settings_cache (parameter_id, process_id, active_setting_count)
--     values ()
--     select count(active_setting_count) into l_violations_count
--     from (select PARAMETER_ID, PROCESS_ID, count(PARAMETER_ID) as active_setting_count
--           from settings
--           where :new.IS_ACTIVE = 'Y'
--           group by (PARAMETER_ID, PROCESS_ID))
--     where active_setting_count > 1;
--     select no_active_settings into l_violations_count from settings_is_valid_counts;
        dbms_output.PUT_LINE('For this row, we get');
    when others then
        raise

--     if l_violations_count > 0 then
--         raise_application_error(-20010, 'Man, this works');
--     end if;

end;
/