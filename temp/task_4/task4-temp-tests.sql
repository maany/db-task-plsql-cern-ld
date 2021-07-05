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
/
/
create unique index enforce_one_is_valid on settings (parameter_id, process_id, nullif(is_active, 'N'));
/
drop index enforce_one_is_valid;
/

