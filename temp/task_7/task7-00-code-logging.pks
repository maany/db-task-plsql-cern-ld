create or replace package logging as
    constraint_violation exception;
    pragma exception_init ( constraint_violation, -2290 );
    procedure error (
        i_component_name varchar2,
        i_message varchar2
    );
    procedure info(
        i_component_name varchar2,
        i_message varchar2
    );
end;