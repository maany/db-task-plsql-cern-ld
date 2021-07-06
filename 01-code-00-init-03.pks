create or replace package setting_utils as
    function get_parameter_id_by_name(
        i_parameter_name varchar2
    ) return number;

    function get_process_id_by_name(
        i_process_name varchar2
    ) return number;

    procedure create_int_setting(
        i_parameter_name varchar2,
        i_process_name varchar2,
        i_value pls_integer
    );

    procedure copy_settings(
        i_src_parameter_name varchar2,
        i_src_process_name varchar2,
        i_dest_parameter_name varchar2,
        i_dest_process_name varchar2
    );

    procedure divide_setting(
        i_numerator_setting in out nocopy t_number,
        i_denominator_setting in t_number
    );
end setting_utils;
/