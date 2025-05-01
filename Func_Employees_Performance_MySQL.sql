drop function if exists get_total_element_assessment_by_condition;
delimiter $$
create function get_total_element_assessment_by_condition(cond varchar(20))
returns int
not deterministic
reads sql data
begin
	declare total int;
	select count(assessment_id) into total from assessment a where a.status = cond ;
    return total;
end $$
delimiter ;




drop function if exists get_total_element_assessment_by_employee_condition;
delimiter $$
create function get_total_element_assessment_by_employee_condition(employeeId int, cond varchar(20))
returns int
not deterministic
reads sql data
begin
	declare total int;
	select count(assessment_id) into total from assessment a where a.employee_id = employeeId and a.status = cond;
    return total;
end $$
delimiter ;



drop function if exists get_total_element_review_by_condition;
delimiter $$
create function get_total_element_review_by_condition(cond varchar(20))
returns int
not deterministic
reads sql data
begin
	declare result int;
    select count(review_id) into result from review where status = cond; 
    return result;
end $$
delimiter ;




drop function if exists get_total_element_review_by_employee_condition;
delimiter $$
create function get_total_element_review_by_employee_condition(employeeId int, cond varchar(20))
returns int
not deterministic
reads sql data
begin
	declare result int;
    select count(review_id) into result from review where status = cond and line_manager_id=employeeId; 
    return result;
end $$
delimiter ;



















