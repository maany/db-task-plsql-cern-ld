create or replace type val_array as varray(1000) of number;
/
create type task8_tf_row
as object
(
    is_active char(1),
    value_type varchar2(30),
    scalar_value number,
    x_values val_array,
    y_values val_array
)

/
create type task_8_tf_tab is table of task8_tf_row;
/


create or replace function render_task_8(
    i_parameter_name IN varchar2,
    i_process_name IN varchar2
) return task_8_tf_tab pipelined
    as
    l_is_active char(1);
    l_value_type varchar2(30);
    l_scalar_value number;
    l_x_values val_array;
    l_y_values val_array;
begin

    pipe row ( task8_tf_row(l_is_active, l_value_type, l_scalar_value, l_x_values, l_y_values ));
    return;
end;

/
select * from Table(render_task_8(1,1))
/