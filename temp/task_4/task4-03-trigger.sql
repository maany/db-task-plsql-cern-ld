create or replace function get_active_setting_id(
    i_parameter_id IN number,
    i_process_id IN number
) return number
    is
    l_setting_id number;
begin
    select active_setting_id
    into l_setting_id
    from SETTINGS_CACHE
    where parameter_id = i_parameter_id
      and process_id = i_process_id;
    return l_setting_id;
exception
    when no_data_found then
        return null;
end;

create or replace function check_record_exists(
    i_parameter_id IN number,
    i_process_id IN number
) return number
    is
    l_setting_id number;
begin
    select active_setting_id
    into l_setting_id
    from SETTINGS_CACHE
    where parameter_id = i_parameter_id
      and process_id = i_process_id;
    return 1;
exception
    when no_data_found then
        return null;
end;

/
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
/
create or
    replace trigger post_check_active_settings
    after
        insert or
        update
    on settings
    for each row
declare
    l_log_message              varchar(256);
    l_currently_active_setting number;
    l_record_exists            number;
begin
    l_log_message :=
                'Trigger POST: [ parameter_id: ' || :new.parameter_id || ', process_id:' || :new.process_id ||
                ']';
    l_currently_active_setting := get_active_setting_id(:new.PARAMETER_ID, :new.PROCESS_ID);
    l_record_exists := check_record_exists(:new.PARAMETER_ID, :new.PROCESS_ID);

    if inserting then
        dbms_output.put_line(l_log_message || 'Inserting into settings_cache');
        if :new.is_active = 'Y' then
            if l_record_exists is not null then
                if l_currently_active_setting is null then
                    -- record does not exist, hence l_curently_active_setting is also null. Insert new record
                    insert into settings_cache(parameter_id, process_id, active_setting_id)
                    values (:new.parameter_id, :new.process_id, :new.setting_id);
                end if;
            end if;

        end if;
    elsif updating then
        dbms_output.put_line(l_log_message || 'Updating settings and syncing settings_cache..');
    end if;
end;


/
create unique index enforce_one_is_valid on settings (parameter_id, process_id, nullif(is_active, 'N'));
/
drop index enforce_one_is_valid;
/

declare
    active_setting_id number;
begin
    active_setting_id := get_active_setting_id(3, 2);
    if active_setting_id is null then
        dbms_output.put_line('Active Setting Id is null');
    else
        dbms_output.put_line('Active Setting Id: ' || active_setting_id);
    end if;
end;
/
update settings
set IS_ACTIVE = 'N'
where setting_id = 5; -- where PARAMETER_ID=1 and process_id=1 and IS_ACTIVE = 'Y';
/
insert into settings (PARAMETER_ID, PROCESS_ID, IS_ACTIVE, VALUE_TYPE)
values (3, 2, 'Y', 'INT');
/
delete
from settings
where SETTING_ID = 9;
/
insert into SETTINGS_CACHE (parameter_id, process_id, active_setting_id)
values (3, 2, null);
/
update SETTINGS_CACHE
set ACTIVE_SETTING_ID = 12
where ACTIVE_SETTING_ID is null;

/
select *
from settings;
select *
from ACTIVE_SETTING_PER_PARAM_PROCESS;
select *
from settings_cache;
/

update settings
set is_active = 'Y'
where parameter_id = 1
  and process_id = 1;
update settings
set is_active = 'Y'
where setting_id = 1;

/
insert into SETTINGS_CACHE (PARAMETER_ID, PROCESS_ID, ACTIVE_SETTING_ID)
values (3, 2, 5);

update settings
set IS_ACTIVE = 'N'
where SETTING_ID = 5;
delete
from SETTINGS_CACHE
where ACTIVE_SETTING_ID = 5;

insert into settings (PARAMETER_ID, PROCESS_ID, IS_ACTIVE, VALUE_TYPE)
values (3, 2, 'Y', 'INT')

update settings set IS_ACTIVE = 'Y' where SETTING_ID = 7;