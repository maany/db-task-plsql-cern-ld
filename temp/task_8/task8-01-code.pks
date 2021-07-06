create or replace package task8 as
    function get_process_name_by_id(
        i_process_id number
    ) return varchar2;

    function get_parameter_name_by_id(
        i_parameter_id number
    ) return varchar2;

    function get_setting_type_from_value_type(
        i_value_type varchar2
    ) return varchar2;

    function get_x_arrays(
        i_setting_id IN number
    ) return val_array;

    function get_y_arrays(
        i_setting_id IN number
    ) return val_array;

    function render_task_8(
        i_parameter_name IN varchar2,
        i_process_name IN varchar2
    ) return task_8_tf_tab pipelined;
end task8;