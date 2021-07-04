-- Creates a sequence called `parameters_seq`. This sequence is used to assign unique autogenerated values to `parameter_id` pk field
-- of the `parameters` table.
-- As CACHE has not been specified, insertions of large numbers of new records could be slow.
-- https://www.techonthenet.com/oracle/sequences.php
create sequence parameters_seq;

-- Create a table called `parameters`. The table has 2 fields.
create table parameters (
  parameter_id number default parameters_seq.nextval constraint parameters_pk primary key,
  /*
   * parameter_id: A field of type `number` with default value = next available value from the `parameters_seq` created above.
   * A primary key constraint is applied to `parameter_id`. This constraint combines `NOT NULL` and `UNIQUE` constraints
   */
  parameter_name varchar2(100) constraint parameters_parameter_name_nn not null
  /*
   * parameter_name: A variable character string of max 100 characters with a `NOT NULL` constraint.
   * i.e. all new records should specify a value for this field at insertion time.
   */
);

-- This statement adds a `unique` constraint named `parameters_parameter_name_uk`to the `parameter_name` field of the `parameters` table
-- The `not null` and `unique` constrains on the `parameter_name` field make it equivalent to a `primary_key`
-- OPTIMIZATION: We can get rid of the sequence and `parameter_id` field?
alter table parameters add constraint parameters_parameter_name_uk unique (parameter_name);

-- Create a sequence
create sequence processes_seq;

create table processes (
  process_id number default processes_seq.nextval constraint processes_pk primary key,
  process_name varchar2(100) constraint processes_process_name_nn not null
);
-- `unique` and `not null` constraints on `process_name`. This is equivalent to primary key constraint
alter table processes add constraint processes_process_name_uk unique (process_name);

--- create a new table to store mapping of setting and its value type
create table setting_value_types (
  value_type varchar2(30) constraint setting_value_types_pk primary key,
  /*
   * string is used as pk. change it to unique and not null? Don't think it is needed. Just use a regular pk
   */
  setting_type varchar2(30) constraint setting_value_types_setting_type_nn not null
);

-- value type can only be 'SETTING_FUNCTIONS' or `SETTING_SCALARS`
-- index this as integers?
-- Also, value_type does not have a unique constraint. So, a setting has a value_type. It is a ManyToOne relationship here.
alter table setting_value_types add constraint setting_value_types_setting_type_chk
  check (setting_type in ('SETTING_FUNCTIONS', 'SETTING_SCALARS'));

-- sequence to create pk for settings table
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

-- is_active can only have values 'Y' or 'N
alter table settings add constraint settings_is_active_chk
  check (is_active in ('Y', 'N'));

-- If a setting is scalar, then it's value is stored here
create table setting_scalars (
  setting_id number constraint setting_scalars_pk primary key,
  setting_value number constraint setting_scalars_setting_value_nn not null
);

alter table setting_scalars add constraint setting_scalars_setting_id_fk foreign key (setting_id) references settings (setting_id);

-- if a setting has value_type 'function', then x and setting_id must be unique and the x_value and y_value are the values for that setting.
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