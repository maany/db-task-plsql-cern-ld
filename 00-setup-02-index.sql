-- create a index on (parameter_id, process_id, {is_active setting}).
-- make it unique to ensure if another setting tries for same parameter_id, process_id tries to set 'is_active' = 'Y',
-- the index should not allow it.
create unique index enforce_one_is_active on settings (parameter_id, process_id, nullif(is_active, 'N'));