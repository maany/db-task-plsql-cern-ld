create table settings_cache
(
    parameter_id      number
        constraint settings_cache_parameter_id_nn not null,
    process_id        number
        constraint settings_cache_process_id_nn not null,
    active_setting_id number
);

alter table settings_cache
    add constraint settings_cache_pk primary key (parameter_id, process_id);

alter table settings_cache
    add constraint settings_cache_parameter_id_fk foreign key (parameter_id) references parameters (parameter_id);

alter table settings_cache
    add constraint settings_cache_process_id_fk foreign key (process_id) references processes (process_id);

-- create a unique to cause inserts/updates on settings cache to fail when cases when a
-- new setting with is_active = 'Y' is attempted to be added to settings table while an active setting is already existing
-- p.s. this works in combination with the trigger
create unique index enforce_one_is_active on settings_cache (nullif(active_setting_id, null));
/