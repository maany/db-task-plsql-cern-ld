create or replace package test_task_4 as -- test that only one setting per process/parameter combo can be is_valid = 'Y'
    function util_get_active_setting(
        i_parameter_id number,
        i_process_id number
    ) return number;

end test_task_4;