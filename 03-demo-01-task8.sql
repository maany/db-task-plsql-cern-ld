-- demonstrates use of task8 package to generate the outputs
select *
from Table (task8.render_task_8(
    task8.get_parameter_name_by_id(1),
    task8.get_process_name_by_id(1)));
/

