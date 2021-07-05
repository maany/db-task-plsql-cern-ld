-- Tests to test the test framework. Testception!
declare
    l_result number;
begin
    l_result := test_framework.TEST_NUMBER(1, 1);
    l_result := TEST_FRAMEWORK.TEST_NUMBER(1, 2);
exception
    when test_framework.VALUES_DO_NOT_MATCH then
        dbms_output.put_line('Exceptions work!');
end;
/
declare
    l_result number;
begin
    l_result := test_framework.TEST_VARCHAR2('hello', 'hello');
    l_result := TEST_FRAMEWORK.TEST_VARCHAR2('hello', 'bye');
exception
    when test_framework.VALUES_DO_NOT_MATCH then
        dbms_output.put_line('Exceptions work!');
end;
/