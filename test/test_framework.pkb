create or replace package body test_framework as

    -- compare 2 numbers
    function test_number(
        i_expected number,
        i_actual number
    ) return number -- 0 if pass, 1 if fail
        is
        l_log_header varchar2(256);
    begin
        l_log_header := 'TEST_NUMBER: Comparing ' || i_expected || ' and ' || i_actual;
        if i_expected = i_actual then
            dbms_output.put_line(l_log_header || ': Passed');
            return 0;
        end if;
        dbms_output.put_line(l_log_header || ': Failed!!!');
        raise values_do_not_match;
    end test_number;

    -- Compare 2 varchar outputs
    function test_varchar2(
        i_expected varchar2,
        i_actual varchar2
    ) return number -- 0 if pass, 1 if fail
        is
        l_log_header varchar2(256);
    begin
        l_log_header := 'TEST_VARCHAR2: Comparing ' || i_expected || ' and ' || i_actual;
        if i_expected = i_actual then
            dbms_output.put_line(l_log_header || ': Passed');
            return 0;
        end if;
        dbms_output.put_line(l_log_header || ': Failed!!!');
        raise VALUES_DO_NOT_MATCH;
    end test_varchar2;

    procedure setup_tests -- create test data
        is
        l_log_header varchar2(256);
    begin
        l_log_header := 'SETUP TESTS: ';
    end setup_tests;


    procedure cleanup_tests -- cleanup test data
        is
         l_log_header varchar2(256);
    begin
         l_log_header := 'ClEANUP TESTS: ';
    end cleanup_tests;
end;