create or replace trigger pre_check_active_settings
    before insert or update
    on settings
    for each row
declare
    l_log_message              varchar(256);
    l_currently_active_setting number;
    l_record_exists            number;
begin
    l_log_message := 'Trigger: [ parameter_id: ' || :new.parameter_id || ', process_id:' || :new.process_id || ']';
    l_currently_active_setting := get_active_setting_id(:new.PARAMETER_ID, :new.PROCESS_ID);
    l_record_exists := check_record_exists(:new.PARAMETER_ID, :new.PROCESS_ID);

    if inserting then
        dbms_output.put_line(l_log_message || 'Inserting into settings table.');
        if :new.is_active = 'Y' then
            if l_record_exists is not null then -- record pre_exists in setting cache
                if l_currently_active_setting is not null then -- there is a currently_active_setting in the existing record
                    raise_application_error(-20220, 'Active setting already exists for [parameter_id, process_id]');
                else -- the currently_active_setting for the existing record in settings_cache is null. this may be moved to the after trigger
                    update SETTINGS_CACHE
                    set ACTIVE_SETTING_ID = :new.setting_id
                    where PROCESS_ID = :new.process_id
                      and PARAMETER_ID = :new.parameter_id;
                end if;
            else -- record does not exist, so insert a new record, this may be moved to the after trigger
                insert into settings_cache(parameter_id, process_id, active_setting_id)
                values (:new.parameter_id, :new.process_id, :new.setting_id);
            end if;
        end if;
    elsif updating then
        dbms_output.put_line(l_log_message || 'Updating settings and syncing settings_cache..');
        if :old.IS_ACTIVE = 'N' and :new.IS_ACTIVE = 'Y' then
            if l_record_exists is not null then -- record exists in settings_cache
                if l_currently_active_setting is not null then -- value exists in settings_cache already
                    if :new.setting_id = l_currently_active_setting then -- cache is in bad state, :new.setting_id was not active, but cached as active
                        dbms_output.put_line(l_log_message || ' setting cache is in bad state. ' || :new.setting_id ||
                                             ' was not active, but was cached as active.');
                    else -- record exists, value exists, raise error that an active setting already exists
                        raise_application_error(-20220, 'An active setting is already present for [parameter_id, process_id]');
                    end if;
                else -- record exists, but value does not exist in settings cache. update settings cache
                    update SETTINGS_CACHE
                    set ACTIVE_SETTING_ID = :new.setting_id
                    where PROCESS_ID = :new.process_id
                      and PARAMETER_ID = :new.parameter_id;
                end if;
            else -- record does not exist in cache, insert new cache entry
                insert into settings_cache(parameter_id, process_id, active_setting_id)
                values (:new.parameter_id, :new.process_id, :new.setting_id);
            end if;
        elsif :old.is_active = 'Y' and :new.is_active = 'N' then
            if l_record_exists is not null then -- record exists in cache
                if l_currently_active_setting is not null then -- record exists, value exists. remove this record from cache
                    delete from SETTINGS_CACHE where parameter_id = :new.parameter_id and process_id = :new.process_id;
                else -- record exists but value does not exists, cache is in bad state
                    dbms_output.put_line(l_log_message || ' setting cache is in bad state. Null active setting found.');
                end if;
            else --  record does not exist in cache, cache is in a bad state.
                dbms_output.put_line(l_log_message || ' setting cache is in bad state. ' || :new.setting_id ||
                                             ' was active, but was NOT cached as active.');
            end if;
        end if;
    end if;
end;