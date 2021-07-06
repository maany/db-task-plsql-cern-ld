create or replace package body task8 as
    function get_process_name_by_id(
        i_process_id number
    ) return varchar2
        is
        l_process_name varchar2(100);
    begin
        select process_name
        into l_process_name
        from processes
        where process_id = i_process_id;
        return l_process_name;
    end get_process_name_by_id;

    function get_parameter_name_by_id(
        i_parameter_id number
    ) return varchar2
        is
        l_parameter_name varchar2(100);
    begin
        select parameter_name
        into l_parameter_name
        from parameters
        where parameter_id = i_parameter_id;
        return l_parameter_name;
    end get_parameter_name_by_id;

    function get_setting_type_from_value_type(
        i_value_type varchar2
    ) return varchar2
        is
        l_setting_type varchar2(30);
    begin
        select setting_type
        into l_setting_type
        from setting_value_types
        where value_type = i_value_type;
        return l_setting_type;
    end get_setting_type_from_value_type;

    function get_x_arrays(
        i_setting_id IN number
    ) return val_array as
        l_x_array val_array := val_array();
    begin
        for record in (select x_value from SETTING_FUNCTIONS where SETTING_ID = i_setting_id)
            loop
                l_x_array.extend;
                l_x_array(l_x_array.LAST) := record.x_value;
            end loop;
        return l_x_array;
    end get_x_arrays;

    function get_y_arrays(
        i_setting_id IN number
    ) return val_array as
        l_y_array val_array := val_array();
    begin
        for record in (select y_value from SETTING_FUNCTIONS where SETTING_ID = i_setting_id)
            loop
                l_y_array.extend;
                l_y_array(l_y_array.LAST) := record.y_value;
            end loop;
        return l_y_array;
    end get_y_arrays;

    function render_task_8(
        i_parameter_name IN varchar2,
        i_process_name IN varchar2
    ) return task_8_tf_tab pipelined
    as
        l_is_active    char(1);
        l_value_type   varchar2(30);
        l_scalar_value number;
        l_x_values     val_array := val_array();
        l_y_values     val_array := val_array();
        l_process_id   number;
        l_parameter_id number;
        l_log_header   varchar(256);
        l_setting_type varchar(30);
    begin
        l_process_id := setting_utils.get_process_id_by_name(i_process_name);
        l_parameter_id := setting_utils.get_parameter_id_by_name(i_parameter_name);
        l_log_header := l_process_id || ', ' || l_parameter_id;
        for record in (select setting_id, is_active, value_type
                       from settings
                       where PARAMETER_ID = l_parameter_id
                         and PROCESS_ID = l_process_id)
            loop
                l_setting_type := get_setting_type_from_value_type(record.value_type);
                dbms_output.PUT_LINE(l_log_header || ' setting_id: ' || record.SETTING_ID);
                dbms_output.PUT_LINE(l_log_header || ' setting_type was: ' || l_setting_type);
                l_is_active := record.is_active;
                l_value_type := record.value_type;
                if l_setting_type = 'SETTING_SCALARS' then
                    select setting_value into l_scalar_value from setting_scalars where setting_id = record.setting_id;
                    dbms_output.PUT_LINE(l_log_header || ' setting_value was: ' || l_scalar_value);
                elsif l_setting_type = 'SETTING_FUNCTIONS' then
                    dbms_output.PUT_LINE(l_log_header || ' need to calculate x and y arrays: ' || l_scalar_value);
                    l_x_values := GET_X_ARRAYS(record.SETTING_ID);
                    l_y_values := GET_Y_ARRAYS(record.SETTING_ID);
                end if;
            end loop;
        pipe row ( task8_tf_row(l_is_active, l_value_type, l_scalar_value, l_x_values, l_y_values));
        return;
    end render_task_8;
end task8;
/
