create table settings_cache
(
    parameter_id         number
        constraint settings_cache_parameter_id_nn not null,
    process_id           number
        constraint settings_cache_process_id_nn not null,
    active_setting_count number
        constraint settings_cache_active_settings_count_nn not null
);

alter table settings_cache
    add constraint settings_cache_parameter_id_fk foreign key (parameter_id) references parameters (parameter_id);

alter table settings_cache
    add constraint settings_cache_process_id_fk foreign key (process_id) references processes (process_id);

alter table settings_cache
    add constraint settings_cache_active_setting_count_chk
        check ( active_setting_count < 2 );

alter table settings_cache
    add constraint settings_cache_pk primary key (parameter_id, process_id);
/
create or replace procedure update_settings_cache(
    i_parameter_id IN number,
    i_process_id IN number,
    i_is_active IN varchar2
)
    is
    l_count number := -1;
    l_log_header varchar2(250);
begin
    l_log_header := '( '  || i_parameter_id || ', ' || i_process_id || ')';
    dbms_output.PUT_LINE('Find existing active_setting_count for' || l_log_header);
    select active_setting_count
    into l_count
    from settings_cache
    where settings_cache.process_id = i_process_id
      and settings_cache.parameter_id = i_parameter_id;
    -- DEBUG info
    dbms_output.PUT_LINE('active_setting_count: ' || l_count || ' for ' || l_log_header);
    dbms_output.PUT_LINE('incoming is_active value: ' || i_is_active);

    -- if a matching (parameter_id, process_id) pk is found, we should update the active_setting_count for the record
    if i_is_active = 'Y' then
        if l_count = 1 then
                l_count := 0;
        elsif l_count = 0 then
            l_count := l_count + 1;
        end if;
    end if;
    dbms_output.PUT_LINE('updated active_setting_count: ' || l_count || ' for ' || l_log_header);
    dbms_output.put_line('Updating table...');
    update settings_cache set  active_setting_count = l_count
    where settings_cache.process_id = i_process_id
      and settings_cache.parameter_id = i_parameter_id;
exception
    when no_data_found then
        dbms_output.PUT_LINE('Exception: no data found!. Inserting new entry for ' || l_log_header);
        if i_is_active = 'Y' then
            dbms_output.PUT_LINE('active_setting_count is 1 for ' || l_log_header);
            insert into settings_cache (parameter_id, process_id, active_setting_count) values (i_parameter_id, i_process_id, 1);
        elsif i_is_active = 'N' then
            dbms_output.PUT_LINE('active_setting_count is 0 for ' || l_log_header);
            insert into settings_cache (parameter_id, process_id, active_setting_count) values (i_parameter_id, i_process_id, 0);
        else
            raise_application_error(-20010, 'Cannot insert record to settings_cache');
        end if;
    when others then
        dbms_output.PUT_LINE('Failed to update settings_cache table!');
end;

/
declare
	I_PARAMETER_ID NUMBER := 4;
	I_PROCESS_ID NUMBER := 3;
	I_IS_ACTIVE VARCHAR2(4000) := 'O';
begin
	UPDATE_SETTINGS_CACHE(
		I_PARAMETER_ID => I_PARAMETER_ID,
		I_PROCESS_ID => I_PROCESS_ID,
		I_IS_ACTIVE => I_IS_ACTIVE
	);

end;
/
select * from settings_cache;

/

create or replace function update_settings_cache(
    i_parameter_id IN number,
    i_process_id IN number,
    i_is_active IN varchar2
)
    return number
    is
    l_count number := -1;
    l_log_header varchar2(250);
begin
    l_log_header := '( '  || i_parameter_id || ', ' || i_process_id || ')';
    dbms_output.PUT_LINE('Find existing active_setting_count for' || l_log_header);
    select active_setting_count
    into l_count
    from settings_cache
    where settings_cache.process_id = i_process_id
      and settings_cache.parameter_id = i_parameter_id;
    -- DEBUG info
    dbms_output.PUT_LINE('active_setting_count: ' || l_count || ' for ' || l_log_header);
    dbms_output.PUT_LINE('incoming is_active value: ' || i_is_active);

    -- if a matching (parameter_id, process_id) pk is found, we should update the active_setting_count for the record
    if i_is_active = 'Y' then
        l_count := l_count + 1;
    end if;
    dbms_output.PUT_LINE('updated active_setting_count: ' || l_count || ' for ' || l_log_header);
    dbms_output.put_line('Updating table...');
    update settings_cache set  active_setting_count = l_count
    where settings_cache.process_id = i_process_id
      and settings_cache.parameter_id = i_parameter_id;
    return 0;
exception
    when no_data_found then
        dbms_output.PUT_LINE('Exception: no data found!. Inserting new entry for ' || l_log_header);
        if i_is_active = 'Y' then
            dbms_output.PUT_LINE('active_setting_count is 1 for ' || l_log_header);
            insert into settings_cache (parameter_id, process_id, active_setting_count) values (i_parameter_id, i_process_id, 1);
            return 0;
        elsif i_is_active = 'N' then
            dbms_output.PUT_LINE('active_setting_count is 0 for ' || l_log_header);
            insert into settings_cache (parameter_id, process_id, active_setting_count) values (i_parameter_id, i_process_id, 0);
            return 0;
        else
            raise_application_error(-20010, 'Cannot insert record to settings_cache');
        end if;
        return 1;
    when others then
        dbms_output.PUT_LINE('Failed to update settings_cache table!');
        return 1;
end;
/