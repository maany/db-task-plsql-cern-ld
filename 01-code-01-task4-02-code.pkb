create or replace package body task4 as -- utils for task 4
    function get_active_setting(
        i_parameter_id number,
        i_process_id number
    ) return number
        is
        l_active_setting_id number;
        l_log_header varchar2(256);
    begin
        l_log_header := '[parameter_id: ' || i_parameter_id || ', process_id: ' || i_process_id || ']';
        select current_active_setting_id into l_active_setting_id
        from active_setting_per_param_process
            where process_id = i_process_id and parameter_id  = i_parameter_id;
        return l_active_setting_id;
    exception
        when no_data_found then
            raise_application_error(-20201, 'No active setting available for '  || l_log_header);
    end get_active_setting;
end task4;
/
declare
    active_setting number;
begin
    active_setting := task4.get_active_setting(1, 1);
    dbms_output.put_line('Active setting' || active_setting);
exception
    when task4.no_active_setting then
    dbms_output.put_line('No active setting found! Skipping this record!');
end;
/