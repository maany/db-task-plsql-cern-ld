create or replace type val_array as varray(1000) of number;

create type task8_tf_row
as object
(
    is_active    char(1),
    value_type   varchar2(30),
    scalar_value number,
    x_values     val_array,
    y_values     val_array
);

create type task_8_tf_tab is table of task8_tf_row;
/