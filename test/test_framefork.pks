create or replace package test_framework as
    -- basic functions/procedures for testing
    function test_number(
        i_expected number,
        i_actual number
    ) return number; -- 0 if pass, 1 if fail

    function test_varchar2(
        i_expected varchar2,
        i_actual varchar2
    ) return number; -- 0 if pass, 1 if fail

    procedure setup_tests; -- create test data
    procedure cleanup_tests; -- cleanup test data

    values_do_not_match exception;

end test_framework;