create sequence parameters_seq;

create table parameters (
  parameter_id number default parameters_seq.nextval constraint parameters_pk primary key,
  parameter_name varchar2(100) constraint parameters_parameter_name_nn not null
);

alter table parameters add constraint parameters_parameter_name_uk unique (parameter_name);

create sequence processes_seq;

create table processes (
  process_id number default processes_seq.nextval constraint processes_pk primary key,
  process_name varchar2(100) constraint processes_process_name_nn not null
);

alter table processes add constraint processes_process_name_uk unique (process_name);

create table setting_value_types (
  value_type varchar2(30) constraint setting_value_types_pk primary key,
  setting_type varchar2(30) constraint setting_value_types_setting_type_nn not null
);
  
alter table setting_value_types add constraint setting_value_types_setting_type_chk 
  check (setting_type in ('SETTING_FUNCTIONS', 'SETTING_SCALARS'));

create sequence settings_seq;

create table settings (
  setting_id number default settings_seq.nextval constraint settings_pk primary key,
  parameter_id number constraint settings_parameter_id_nn not null,
  process_id number constraint settings_process_id_nn not null,
  is_active char(1) constraint settings_is_active_nn not null,
  value_type varchar2(30) constraint settings_value_type_nn not null
);

alter table settings add constraint settings_parameter_id_fk foreign key (parameter_id) references parameters (parameter_id);

alter table settings add constraint settings_process_id_fk foreign key (process_id) references processes (process_id);

alter table settings add constraint settings_value_type_fk foreign key (value_type) references setting_value_types (value_type);

alter table settings add constraint settings_is_active_chk 
  check (is_active in ('Y', 'N'));
  
create table setting_scalars (
  setting_id number constraint setting_scalars_pk primary key,
  setting_value number constraint setting_scalars_setting_value_nn not null
);

alter table setting_scalars add constraint setting_scalars_setting_id_fk foreign key (setting_id) references settings (setting_id);

create table setting_functions (
  setting_id number,
  x_value number,
  y_value number constraint setting_functions_y_value_nn not null,
  constraint setting_functions_pk primary key (setting_id, x_value)
);

alter table setting_functions add constraint setting_functions_setting_id_fk foreign key (setting_id) references settings (setting_id);

create sequence log_seq;

create table log_messages (
  log_id number default log_seq.nextval constraint log_messages_pk primary key,
  tstamp timestamp default systimestamp constraint log_messages_tstamp_nn not null, 
  message varchar2(4000) constraint log_messages_message_nn not null
);
  
create type t_number is table of number;