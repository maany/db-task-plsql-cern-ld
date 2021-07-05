create table settings_cache
(
    parameter_id         number
        constraint settings_cache_parameter_id_nn not null,
    process_id           number
        constraint settings_cache_process_id_nn not null,
    active_setting_id number default -1
        constraint settings_cache_active_settings_id_nn not null
);

alter table settings_cache
    add constraint settings_cache_pk primary key (parameter_id, process_id);

alter table settings_cache
    add constraint settings_cache_parameter_id_fk foreign key (parameter_id) references parameters (parameter_id);

alter table settings_cache
    add constraint settings_cache_process_id_fk foreign key (process_id) references processes (process_id);

alter table settings_cache
    add constraint settings_cache_active_setting_id_fk foreign key (active_setting_id) references settings (setting_id);

