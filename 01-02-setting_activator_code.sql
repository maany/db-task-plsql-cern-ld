create or replace procedure activate_setting(
    i_parameter_id IN number,
    i_process_id IN number,
    i_setting_id IN number,
    i_is_active IN varchar
)
    is
--     update_required exception;
--     pragma exception_init ( update_required, -20201);
    l_active_setting_id number;
    l_log_header varchar2(250);
begin
    l_log_header := '( '  || i_parameter_id || ', ' || i_process_id || ')';
    dbms_output.PUT_LINE('Find currently active setting for ' || l_log_header);

    select active_setting_id
    into l_active_setting_id
    from settings_cache
    where settings_cache.process_id = i_process_id
      and settings_cache.parameter_id = i_parameter_id;
    -- DEBUG info
    dbms_output.PUT_LINE('active_setting_id: ' || l_active_setting_id || ' for ' || l_log_header);
    dbms_output.PUT_LINE('setting to check : ' || i_setting_id);

    -- if a matching (parameter_id, process_id) pk is found, we should update the active_setting_id for the record
    if l_active_setting_id != i_setting_id then
        if i_is_active = 'Y' then
            -- deactivate old setting and activate new setting
            dbms_output.put_line('Activating new setting ' || i_setting_id);
            update settings_cache set SETTINGS_CACHE.active_setting_id = i_setting_id where settings_cache.process_id = i_process_id and settings_cache.parameter_id = i_parameter_id;
            dbms_output.put_line('Deactivating old setting ' || l_active_setting_id);
            update settings set is_active = 'N' where settings.setting_id = l_active_setting_id;
        end if;
    end if;
exception
    when no_data_found then
        dbms_output.PUT_LINE('Exception: no data found for ' || l_log_header);
        if i_is_active = 'Y' then
            dbms_output.PUT_LINE('active_setting for  ' || l_log_header);
            insert into settings_cache (parameter_id, process_id, active_setting_id) values (i_parameter_id, i_process_id, i_setting_id);
        elsif i_is_active = 'N' then
            dbms_output.PUT_LINE('No active settings  for ' || l_log_header);
        else
            raise_application_error(-20010, 'Cannot insert record to settings_cache');
        end if;
--     when others then
--         dbms_output.PUT_LINE('Failed to update settings_cache table!');
end;
