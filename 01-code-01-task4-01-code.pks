create or replace package task4 as
    -- utils for task 4
    function get_active_setting(
        i_parameter_id number,
        i_process_id number
    ) return number;

    function get_active_setting_id(
        i_parameter_id IN number,
        i_process_id IN number
    ) return number;

    function check_record_exists(
        i_parameter_id IN number,
        i_process_id IN number
    ) return number;

    -- Exception in case no record is found for (parameter_id, process_id) in active_setting_per_param_process view
    no_active_setting exception;
    pragma exception_init ( no_active_setting, -20201);
end task4;