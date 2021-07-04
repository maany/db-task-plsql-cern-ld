insert into setting_value_types (value_type,setting_type) values ('FUNCTION','SETTING_FUNCTIONS');
insert into setting_value_types (value_type,setting_type) values ('DOUBLE','SETTING_SCALARS');
insert into setting_value_types (value_type,setting_type) values ('INT','SETTING_SCALARS');

insert into parameters (parameter_id, parameter_name) values (parameters_seq.nextval, 'SCALAR_PARAM_01');
insert into parameters (parameter_id, parameter_name) values (parameters_seq.nextval, 'SCALAR_PARAM_02');
insert into parameters (parameter_id, parameter_name) values (parameters_seq.nextval, 'FUNCTION_PARAM_01');
insert into parameters (parameter_id, parameter_name) values (parameters_seq.nextval, 'FUNCTION_PARAM_02');

insert into processes (process_id, process_name) values (processes_seq.nextval, 'PROCESS_01');
insert into processes (process_id, process_name) values (processes_seq.nextval, 'PROCESS_02');

exec create_int_setting ('SCALAR_PARAM_01', 'PROCESS_01', 1);
exec create_int_setting ('SCALAR_PARAM_01', 'PROCESS_01', 2);

exec copy_settings ('SCALAR_PARAM_01', 'PROCESS_01', 'SCALAR_PARAM_02', 'PROCESS_02');

insert into settings (setting_id, parameter_id, process_id, is_active, value_type)
values (settings_seq.nextval, get_parameter_id_by_name('FUNCTION_PARAM_01'), get_process_id_by_name('PROCESS_02'), 'Y', 'FUNCTION');

insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.0, -3.0);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.1, 0);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.3, 2.3);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.35, .7);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.5, -1.1);

insert into settings (setting_id, parameter_id, process_id, is_active, value_type)
values (settings_seq.nextval, get_parameter_id_by_name('FUNCTION_PARAM_02'), get_process_id_by_name('PROCESS_02'), 'Y', 'FUNCTION');

insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.0, 3.0);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.1, 2.0);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.3, 10.0);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.35, 0.0);
insert into setting_functions (setting_id, x_value, y_value) values (settings_seq.currval, 0.5, -1.0);

commit;