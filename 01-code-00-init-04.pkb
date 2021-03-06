create or replace package body setting_utils as
    -- function to query parameters table and retrieve parameter_id for the given i_parameter_name
    function get_parameter_id_by_name(
        i_parameter_name varchar2 -- input parameter of type varchar2
    ) return number
        is
        -- local scoped variable of type number
        l_parameter_id number;
    begin
        -- query to set l_parameter_id
        select parameter_id
        into l_parameter_id
        from parameters
        where parameter_name = i_parameter_name;
        -- return the retrieved parameter_id
        return l_parameter_id; -- missing exception handling
    end;
    -- function to query process table and retrieve the process_id for given process_name
    function get_process_id_by_name(
        i_process_name varchar2
    ) return number
        is
        l_process_id number;
    begin
        select process_id
        into l_process_id
        from processes
        where process_name = i_process_name;
        return l_process_id;
    end;
    --
    procedure create_int_setting(
        i_parameter_name varchar2,
        i_process_name varchar2,
        i_value pls_integer
    )
        is
        l_log_message varchar2(3500);
        l_setting_id  number;

    begin
        l_log_message := 'i_parameter_name=' || i_parameter_name
            || '; i_process_name=' || i_process_name || '; i_value=' || i_value;
        insert into log_messages (message)
        values ('create_int_setting: i_parameter_name=' || i_parameter_name
            || '; i_process_name=' || i_process_name || '; i_value=' || i_value);
        -- disable all settings for given (param_id, process_id) combos
        update settings
        set is_active = 'N'
        where is_active = 'Y'
          and parameter_id = get_parameter_id_by_name(i_parameter_name)
          and process_id = get_process_id_by_name(i_process_name);
        -- insert a new active setting into settings table
        insert into settings (setting_id, parameter_id, process_id, is_active, value_type)
        values (settings_seq.nextval, get_parameter_id_by_name(i_parameter_name),
                get_process_id_by_name(i_process_name),
                'Y', 'INT')
        returning setting_id into l_setting_id;
        -- add the value of the setting into the setting_scalars table
        insert into setting_scalars (setting_id, setting_value)
        values (l_setting_id, i_value);
        -- update logs
        insert into log_messages (message) values ('create_int_setting: done');
    exception
        when others then
            logging.ERROR('create_int_setting', 'FAILED!' || l_log_message);
    end;
    -- copies all settings for given (src_parameter_id, src_process_id) to a new (dest_parameter_id, dest_source_id)
    procedure copy_settings(
        i_src_parameter_name varchar2,
        i_src_process_name varchar2,
        i_dest_parameter_name varchar2,
        i_dest_process_name varchar2
    )
        is

        l_src_parameter_id  number;
        l_dest_parameter_id number;
        l_src_process_id    number;
        l_dest_process_id   number;
        l_new_setting_id    number;
        l_log_header        varchar2(3500);
    begin
        l_log_header := 'i_src_parameter_name=' || i_src_parameter_name
            || '; i_src_process_name=' || i_src_process_name || '; i_dest_parameter_name=' || i_dest_parameter_name ||
                        '; i_dest_process_name=' || i_dest_process_name;
        insert into log_messages (message)
        values ('copy_settings: i_src_parameter_name=' || l_log_header);

        select parameter_id
        into l_src_parameter_id
        from parameters
        where parameter_name = i_src_parameter_name;

        select parameter_id
        into l_dest_parameter_id
        from parameters
        where parameter_name = i_dest_parameter_name;

        select process_id
        into l_src_process_id
        from processes
        where process_name = i_src_process_name;

        select process_id
        into l_dest_process_id
        from processes
        where process_name = i_dest_process_name;

        for x in (
            select *
            from settings
            where parameter_id = l_src_parameter_id
              and process_id = l_src_process_id)
            loop
                select settings_seq.nextval
                into l_new_setting_id
                from dual;

                insert into settings (setting_id, parameter_id, process_id, is_active, value_type)
                values (l_new_setting_id, l_dest_parameter_id, l_dest_process_id, x.is_active, x.value_type);

                insert into setting_scalars (setting_id, setting_value)
                select l_new_setting_id, setting_value
                from setting_scalars
                where setting_id = x.setting_id;

                insert into setting_functions (setting_id, x_value, y_value)
                select l_new_setting_id, x_value, y_value
                from setting_functions
                where setting_id = x.setting_id;

            end loop;

        insert into log_messages (message) values ('copy_settings: done');
    exception
        when no_data_found then
            logging.error('copy_settings', 'No data found in while querying existing tables for ' || l_log_header);
            logging.info('copy_settings', 'Rolling back!');
            rollback;
        when value_error then
            logging.error('copy_settings',
                          'VALUE_ERROR. Potentially due to casting error or size mismatches' || l_log_header);
            logging.info('copy_settings', 'Rolling back!');
            rollback;
        when logging.constraint_violation then
            logging.error('copy_settings', 'CONSTRAINT VIOLATION when inserting new records. ' || l_log_header);
            rollback;
        when invalid_number then
            logging.error('copy_settings', 'INVALID_NUMBER in SQL statement ' || l_log_header);
            rollback;
        when storage_error then
            logging.error('copy_settings', 'Out of storage space! Buy beers for your DBA');
            rollback;
        when timeout_on_resource then
            logging.error('copy_settings', 'Timeout! Check connection or potential deadlock.');
            rollback;
        when others then
            logging.info('copy_settings', 'Unknown error! Rolling back!');
            rollback;
    end ;

    -- for function type settings, evaluates (numerator/denominator) and stores the result in i_numberator_setting.
    procedure divide_setting(
        i_numerator_setting in out nocopy t_number, -- t_number is a table of number type records
        i_denominator_setting in t_number
    )
        is

    begin

        if i_numerator_setting.count <> i_denominator_setting.count then
            raise value_error;
        end if;

        for indx in i_numerator_setting.first .. i_numerator_setting.last
            loop

                i_numerator_setting(indx) := i_numerator_setting(indx) / i_denominator_setting(indx);

            end loop;

    end;

end setting_utils;
/
