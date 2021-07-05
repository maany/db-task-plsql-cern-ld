select * from SETTING_SCALARS;
/
select * from SETTING_FUNCTIONS;
/
select PROCESS_ID, PARAMETER_ID from settings group by settings.PROCESS_ID, settings.PARAMETER_ID;
/
select * from settings;
/
create or replace function get_x_arrays(
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
end;
-- x array
/
create or replace function get_y_arrays(
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
end;