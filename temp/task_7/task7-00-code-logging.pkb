create or replace package body logging as
    procedure error(
        i_component_name varchar2,
        i_message varchar2
    ) is
    begin
        insert into LOG_MESSAGES (message) values ('error: ' || i_component_name || ': ' || i_message);
    end error;


    procedure info(
        i_component_name varchar2,
        i_message varchar2
    ) is
    begin
        insert into LOG_MESSAGES (message) values ('INFO: ' || i_component_name || ': ' || i_message);
    end info;
end;