create or replace package body task4 as
    -- utils for task 4
    function get_active_setting(
        i_parameter_id number,
        i_process_id number
    ) return number
        is
        l_active_setting_id number;
        l_log_header        varchar2(256);
    begin
        l_log_header := '[parameter_id: ' || i_parameter_id || ', process_id: ' || i_process_id || ']';
        select current_active_setting_id
        into l_active_setting_id
        from active_setting_per_param_process
        where process_id = i_process_id
          and parameter_id = i_parameter_id;
        return l_active_setting_id;
    exception
        when no_data_found then
            raise_application_error(-20201, 'No active setting available for ' || l_log_header);
    end get_active_setting;

    /*
     * if record for (parameter_id, process_id) exists in settings_cache, return 1, else return null
     */
    function check_record_exists(
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
    end check_record_exists;

    /*
     * if record for (parameter_id, process_id) exists in settings_cache, return active_setting_id, else return null
     */
    function get_active_setting_id(
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
end task4;
/
