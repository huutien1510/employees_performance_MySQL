use employees_performance;

drop procedure if exists login;

delimiter $$
create procedure login(IN username varchar(50), IN pwd varchar(1000))
begin 
	select a.account_id, e.employee_id, a.username, a.pwd, a.acc_role
    from 
    (select account_id, username, pwd, acc_role from account t where t.username = username and t.pwd = pwd) a 
    left join (select employee_id, account_id from employees) e
    on a.account_id = e.account_id;
end; $$

delimiter ;





drop procedure if exists get_all_kpi_name;
delimiter $$
create procedure get_all_kpi_name()
begin
	select kpi_id,kpi_name
    from kpi;
end $$
delimiter ;




drop procedure if exists get_all_kpi_name_by_year;
delimiter $$
create procedure get_all_kpi_name_by_year(in years int)
begin
	select kpi_id,kpi_name
    from kpi
    where kpi_year = years;
end $$
delimiter ;





drop procedure if exists get_all_kpa_name_by_kpi;
delimiter $$
create procedure get_all_kpa_name_by_kpi(in kpi_id int)
begin
	select kpa_id,kpa_name
    from kpa k
    where k.kpi_id = kpi_id;
end $$
delimiter ;






drop procedure if exists get_all_kpa_by_kpi;
delimiter $$
create procedure get_all_kpa_by_kpi(in kpi_id int, in employeeId int)
begin
	select k.kpa_id,kpa_name, percent, r.evaluate 
    from 
    (select kpa_id,kpa_name, percent from kpa a where a.kpi_id = kpi_id) k
    left join 
    (select kpa_id, SUM(evaluate) as evaluate from review where employee_id = employeeId group by kpa_id) r 
    on r.kpa_id = k.kpa_id ;
end $$
delimiter ;






drop procedure if exists get_all_assessment_by_employee;
delimiter $$
create procedure get_all_assessment_by_employee(in employeeId int,in pages int, in size int)
begin
	declare skips int;
    set skips = pages * size;
	
	SELECT 
  a.assessment_id,
  a.employee_id,
  e.name,
  e.job_title,
  e.avatar as employee_avatar,
  l.line_manager_id,
  l.line_manager_name,
  l.line_manager_job_title,
  l.avatar as line_manager_avatar,
  a.kpa_id,
  c.kpa_name,
  a.kpi_id,
  b.kpi_name,
  a.evaluate,
  a.comments,
  a.link,
  a.status,
  a.created_at,
  a.updated_at
	FROM assessment a
	JOIN (
	SELECT employee_id, name, job_title, avatar FROM employees
	) e ON e.employee_id = a.employee_id
    JOIN (
	SELECT employee_id as line_manager_id, name as line_manager_name, job_title as line_manager_job_title, avatar FROM employees
	) l ON l.line_manager_id = a.line_manager_id
	JOIN (
	SELECT kpa_id, kpa_name FROM kpa
	) c ON c.kpa_id = a.kpa_id
	JOIN (
	SELECT kpi_id, kpi_name FROM kpi
	) b ON b.kpi_id = a.kpi_id
	WHERE a.employee_id = employeeId
    order by updated_at desc
    limit size offset skips;
end $$
delimiter ;





drop procedure if exists get_assessment_by_employee_page_parameters;
delimiter $$
create procedure get_assessment_by_employee_page_parameters(in employeeId int)
begin
	select
	get_total_element_assessment_by_employee_condition(employeeId, "reviewed") as reviewed, 
	get_total_element_assessment_by_employee_condition(employeeId, "pending") as pending,
	get_total_element_assessment_by_employee_condition(employeeId, "cancel") as cancel;
end $$
delimiter ;



drop procedure if exists get_all_assessment;
delimiter $$
create procedure get_all_assessment(in pages int, in size int)
begin
declare skips int;
set skips := pages * size;

	SELECT 
  a.assessment_id,
  a.employee_id,
  e.name,
  e.job_title,
  e.avatar as employee_avatar,
  l.line_manager_id,
  l.line_manager_name,
  l.line_manager_job_title,
  l.avatar as line_manager_avatar,
  a.kpa_id,
  c.kpa_name,
  a.kpi_id,
  b.kpi_name,
  a.evaluate,
  a.comments,
  a.link,
  a.status,
  a.created_at,
  a.updated_at
	FROM assessment a
	JOIN (
	SELECT employee_id, name, job_title, avatar FROM employees
	) e ON e.employee_id = a.employee_id
    JOIN (
	SELECT employee_id as line_manager_id, name as line_manager_name, job_title as line_manager_job_title, avatar FROM employees
	) l ON l.line_manager_id = a.line_manager_id
	JOIN (
	SELECT kpa_id, kpa_name FROM kpa
	) c ON c.kpa_id = a.kpa_id
	JOIN (
	SELECT kpi_id, kpi_name FROM kpi
	) b ON b.kpi_id = a.kpi_id
    order by updated_at desc
    limit size offset skips;
end $$
delimiter ;




drop procedure if exists get_assessment_page_parameters;
delimiter $$
create procedure get_assessment_page_parameters()
begin
	select
	get_total_element_assessment_by_condition("reviewed") as reviewed, 
	get_total_element_assessment_by_condition("pending") as pending,
	get_total_element_assessment_by_condition("cancel") as cancel;
end $$
delimiter ;




drop procedure if exists get_all_employees;
delimiter $$
create procedure get_all_employees(in pages int, in size int)
begin
	declare skips int;
	set skips := pages * size;
	select 
    e.employee_id,
    e.name,
    e.email,
    e.phone,
    e.job_title,
    e.birth_date,
    e.start_date,
    e.end_date,
    e.avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.email as line_manager_mail,
    l.avatar as line_manager_avatar,
    d.department_id,
    d.department_name
    from 
    (select employee_id, name, email, phone, job_title, birth_date, start_date, end_date, avatar, department_id from employees) e
    left join
    (select employee_id, line_manager_id from manage_info where (now()>start_date and ((end_date is null) or (now()<end_date)))) m on e.employee_id = m.employee_id
    left join
    (select employee_id, name, job_title, email, avatar from employees) l on m.line_manager_id = l.employee_id
    join
    (select department_id, department_name from departments) d on e.department_id = d.department_id
    limit size offset skips;
end $$
delimiter ;





drop procedure if exists get_all_employees_admin;
delimiter $$
create procedure get_all_employees_admin(in pages int, in size int)
begin
	declare skips int;
	set skips := pages * size;
	select 
    e.employee_id,
    e.name,
    e.email,
    e.phone,
    e.job_title,
    e.birth_date,
    e.avatar,
    COUNT(CASE WHEN r.status = 'reviewed' THEN 1 END) AS reviewed,
    COUNT(CASE WHEN r.status = 'pending' THEN 1 END) AS pending
    from 
    (select employee_id, name, email, phone, job_title, birth_date, avatar from employees) e
	LEFT JOIN review r ON r.employee_id = e.employee_id
	GROUP BY e.employee_id
    limit size offset skips;
end $$
delimiter ;






drop procedure if exists get_all_employee_sidebar;
delimiter $$
create procedure get_all_employee_sidebar()
begin
	SELECT 
    e.employee_id,
    e.name,
    COUNT(CASE WHEN r.status = 'reviewed' THEN 1 END) AS reviewed,
    COUNT(CASE WHEN r.status = 'pending' THEN 1 END) AS pending
	FROM employees e
    LEFT JOIN review r ON r.employee_id = e.employee_id
	GROUP BY e.employee_id;
end $$
delimiter ;






drop procedure if exists get_all_manager_sidebar;
delimiter $$
create procedure get_all_manager_sidebar()
begin
	SELECT 
    e.employee_id,
    e.name,
    COUNT(CASE WHEN r.status = 'reviewed' THEN 1 END) AS reviewed,
    COUNT(CASE WHEN r.status = 'pending' THEN 1 END) AS pending
	FROM employees e
	JOIN 
	(select line_manager_id from manage_info group by line_manager_id) m ON m.line_manager_id = e.employee_id
	LEFT JOIN review r ON r.line_manager_id = e.employee_id
	GROUP BY e.employee_id;
end $$
delimiter ;





drop procedure if exists get_all_reviews;
delimiter $$
create procedure get_all_reviews(in pages int, in size int)
begin
	declare skips int;
	set skips := pages * size;
	select 
    r.review_id,
    r.assessment_id,
    e.employee_id,
    e.name,
    e.job_title as employee_job_title,
    e.avatar as employee_avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.avatar as line_manager_avatar,
    a.kpa_id,
    a.kpa_name,
    i.kpi_id,
    i.kpi_name,
    r.employee_evaluate,
    r.employee_comments,
    r.employee_link,
    r.evaluate,
    r.comments,
    r.status,
    r.updated_at
    from 
    (select review_id, line_manager_id, assessment_id, employee_id, kpa_id, kpi_id,employee_evaluate, employee_comments, employee_link, evaluate, comments, status, updated_at from review ) r
    join 
    (select employee_id, name, job_title, avatar from employees) e on r.employee_id = e.employee_id 
    join 
    (select employee_id, name, job_title, avatar from employees) l on r.line_manager_id = l.employee_id
    join
    (select kpa_id, kpa_name from kpa) a on r.kpa_id = a.kpa_id
    join
    (select kpi_id, kpi_name from kpi) i on r.kpi_id = i.kpi_id
    order by updated_at desc
    limit size offset skips;
end $$
delimiter ;




drop procedure if exists get_all_reviews_by_line_manager;
delimiter $$
create procedure get_all_reviews_by_line_manager(in employeeId int, in pages int, in size int)
begin
	declare skips int;
	set skips := pages * size;
	select 
    r.review_id,
    r.assessment_id,
    e.employee_id,
    e.name,
    e.job_title as employee_job_title,
    e.avatar as employee_avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.avatar as line_manager_avatar,
    a.kpa_id,
    a.kpa_name,
    i.kpi_id,
    i.kpi_name,
    r.employee_evaluate,
    r.employee_comments,
    r.employee_link,
    r.evaluate,
    r.comments,
    r.status,
    r.updated_at
    from 
    (select review_id, line_manager_id, assessment_id, employee_id, kpa_id, kpi_id,employee_evaluate, employee_comments, employee_link, evaluate, comments, status, updated_at from review ) r
    join 
    (select employee_id, name, job_title, avatar from employees) e on r.employee_id = e.employee_id 
    join 
    (select employee_id, name, job_title, avatar from employees) l on r.line_manager_id = l.employee_id
    join
    (select kpa_id, kpa_name from kpa) a on r.kpa_id = a.kpa_id
    join
    (select kpi_id, kpi_name from kpi) i on r.kpi_id = i.kpi_id
    where r.line_manager_id = employeeId
    order by updated_at desc
    limit size offset skips;
end $$
delimiter ;






drop procedure if exists get_all_reviews_by_employee;
delimiter $$
create procedure get_all_reviews_by_employee(in employeeId int, in pages int, in size int)
begin
	declare skips int;
	set skips := pages * size;
	select 
    r.review_id,
    r.assessment_id,
    e.employee_id,
    e.name,
    e.job_title as employee_job_title,
    e.avatar as employee_avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.avatar as line_manager_avatar,
    a.kpa_id,
    a.kpa_name,
    i.kpi_id,
    i.kpi_name,
    r.employee_evaluate,
    r.employee_comments,
    r.employee_link,
    r.evaluate,
    r.comments,
    r.status,
    r.updated_at
    from 
    (select review_id, line_manager_id, assessment_id, employee_id, kpa_id, kpi_id,employee_evaluate, employee_comments, employee_link, evaluate, comments, status, updated_at from review ) r
    join 
    (select employee_id, name, job_title, avatar from employees) e on r.employee_id = e.employee_id 
    join 
    (select employee_id, name, job_title, avatar from employees) l on r.line_manager_id = l.employee_id
    join
    (select kpa_id, kpa_name from kpa) a on r.kpa_id = a.kpa_id
    join
    (select kpi_id, kpi_name from kpi) i on r.kpi_id = i.kpi_id
    where r.employee_id = employeeId
    order by updated_at desc
    limit size offset skips;
end $$
delimiter ;






drop procedure if exists get_review_page_parameters;
delimiter $$
create procedure get_review_page_parameters()
begin
	select 
    get_total_element_review_by_condition("reviewed") as reviewed,
    get_total_element_review_by_condition("pending") as pending,
    get_total_element_review_by_condition("cancel") as cancel;
end $$
delimiter ;




drop procedure if exists get_review_page_parameters_by_employee;
delimiter $$
create procedure get_review_page_parameters_by_employee(in employeeId int)
begin
	select 
    get_total_element_review_by_employee_condition(employeeId, "reviewed") as reviewed,
    get_total_element_review_by_employee_condition(employeeId, "pending") as pending,
    get_total_element_review_by_employee_condition(employeeId, "cancel") as cancel;
end $$
delimiter ;





drop procedure if exists evaluate_assessment;
delimiter $$
create procedure evaluate_assessment(in accountId int, in assessmentId int, in evaluate int, in comments text, in updatedAt datetime)
begin
	declare n,i int;
    main_block:begin
    set n= accountId;
    set i= (select a.line_manager_id from assessment a where a.assessment_id = assessmentId);
	
	if (n is null) or not (n=i or n=1) 
    then 
		SIGNAL SQLSTATE '45001' 
		SET message_text = 'Người dùng không có quyền đánh giá báo cáo này';
        leave main_block;
    end if;
    
    update review r
    set r.evaluate = evaluate,
		r.comments = comments,
        r.status = "reviewed",
        r.updated_at = updatedAt
    where r.assessment_id = assessmentId;
    
    update assessment a
    set a.status = "reviewed"
    where a.assessment_id = assessmentId;
    
    select updatedAt, comments;
    end main_block;
    
end $$
delimiter ;






drop procedure if exists update_assessment;
delimiter $$
create procedure update_assessment(in employeeId int, in assessmentId int ,in kpiId int,in kpaId int,in evaluate int,in comments text,in link varchar(255))
begin
	main_block:begin
	declare n,i int;
    set n = employeeId;
    set i = (select employee_id from assessment a where a.assessment_id = assessmentId);
    
    if (n is null or i is null or not (n=i or n=1))
    then
		signal sqlstate '45002'
		set message_text = 'Người dùng không có quyền cập nhật assessment';
    leave main_block;
    end if;
    
    update assessment a
    set a.kpi_id = kpiId,
		a.kpa_id = kpaId,
        a.evaluate = evaluate,
        a.comments = comments,
        a.link = link
	where a.assessment_id = assessmentId;
    
    select kpiId, kpaId, evaluate, comments, link;
    
    end main_block;
    
    
end $$
delimiter ;




drop procedure if exists get_all_reviews_employee_by_year;
delimiter $$
create procedure get_all_reviews_employee_by_year(in employeeId int, in years int)
begin
	declare done boolean default FALSE;
	declare review_evaluate, kpa_percent, kpi_percent, total int;
	declare temp_cursor cursor for
	select 
    SUM(r.review_evaluate) as review_evaluate,
    any_value(a.kpa_percent) as kpa_percent,
    any_value(i.kpi_percent) as kpi_percent
    from 
    (select kpa_id, kpi_id, evaluate as review_evaluate from review where employee_id = employeeId) r
    join
    (select kpa_id, percent as kpa_percent from kpa) a on r.kpa_id = a.kpa_id
    join
    (select kpi_id, percent as kpi_percent from kpi where kpi_year = years ) i on r.kpi_id = i.kpi_id
    group by a.kpa_id;  
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    open temp_cursor;
    set total=0;
    
    read_loop: loop
    
    fetch temp_cursor into review_evaluate, kpa_percent, kpi_percent;
	if done then leave read_loop;
    end if;
    
    if (review_evaluate is null or review_evaluate<0) then set review_evaluate=0;
    elseif (review_evaluate>100) then set review_evaluate = 100;
    end if;    
    
    set total = total + (review_evaluate * kpa_percent /100 * kpi_percent /100);
    end loop;
	
    select total;
    close temp_cursor;
end$$
delimiter ;





drop procedure if exists get_employee_manager;
delimiter $$
create procedure get_employee_manager(in employeeId int)
begin
	select
    e.employee_id,
    e.name,
    e.job_title,
    e.avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.avatar as line_manager_avatar
    from
    (select employee_id, name, job_title, avatar from employees where employee_id = employeeId) e
    left join
    (select employee_id, line_manager_id from manage_info where (now()>start_date and ((end_date is null) or (now()<end_date)))) m on e.employee_id = m.employee_id
    left join
    (select employee_id, name, job_title, avatar from employees) l on m.line_manager_id = l.employee_id;
end $$
delimiter ;





drop procedure if exists create_assessment;
delimiter $$
create procedure create_assessment(in token int, in employeeId int, in lineManagerId int, in kpiId int, in kpaId int, in evaluate int, in comments text, in link varchar(255), in createdAt datetime, in updatedAt datetime)
begin
start transaction;
	main_block : begin
    
	if (token <> employeeId) then
		signal sqlstate "45003"
		set message_text = "Người dùng không có quyền tạo assessment cho nhân viên này";
        leave main_block;
	end if;
    
    insert into assessment(employee_id,line_manager_id,kpi_id,kpa_id,evaluate,comments,link,created_at,updated_at) 
    values(employeeId,lineManagerId,kpiId,kpaId,evaluate,comments,link,createdAt,updatedAt);
    
    select employeeId,lineManagerId,kpiId,kpaId,evaluate,comments,link,createdAt,updatedAt;
	end main_block;
commit;
    
end $$
delimiter ;





drop procedure if exists delete_assessment_by_id;
delimiter $$
create procedure delete_assessment_by_id(in assessmentId int)
begin
	delete from assessment where assessment_id = assessmentId;
    select 1;
end $$
delimiter ;





drop procedure if exists get_evaluation_by_kpi;
delimiter $$
create procedure get_evaluation_by_kpi(in kpiId int, in employeeId int)
begin
	
	select SUM(evaluates*k.percent/100)
    from 
    (select kpa_id, percent from kpa where kpi_id = kpiId) k
    join
    (select LEAST(GREATEST(0,SUM(evaluate)),100) as evaluates, kpa_id from review where employee_id = employeeId  group by kpa_id) r
    on k.kpa_id = r.kpa_id;
end $$
delimiter ;

select SUM(evaluates*k.percent/100)
    from 
    (select kpa_id, percent from kpa where kpi_id = 9) k
    join
    (select LEAST(GREATEST(0,SUM(evaluate)),100) as evaluates, kpa_id from review where employee_id = 1  group by kpa_id) r
    on k.kpa_id = r.kpa_id;





drop procedure if exists get_all_employees_by_name;
delimiter $$
create procedure get_all_employees_by_name(in keyword text)
begin
	select 
    e.employee_id,
    e.name,
    e.email,
    e.phone,
    e.job_title,
    e.birth_date,
    e.start_date,
    e.end_date,
    e.avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.email as line_manager_mail,
    l.avatar as line_manager_avatar,
    d.department_id,
    d.department_name
    from 
    (select employee_id, name, email, phone, job_title, birth_date, start_date, end_date, avatar, department_id from employees WHERE name LIKE CONCAT('%', keyword, '%')) e
    left join
    (select employee_id, line_manager_id from manage_info where (now()>start_date and ((end_date is null) or (now()<end_date)))) m on e.employee_id = m.employee_id
    left join
    (select employee_id, name, job_title, email, avatar from employees) l on m.line_manager_id = l.employee_id
    join
    (select department_id, department_name from departments) d on e.department_id = d.department_id;
end $$
delimiter ;





drop procedure if exists get_all_assessment_by_name;
delimiter $$
create procedure get_all_assessment_by_name(in keyword text)
begin
	SELECT 
  a.assessment_id,
  a.employee_id,
  e.name,
  e.job_title,
  e.avatar as employee_avatar,
  l.line_manager_id,
  l.line_manager_name,
  l.line_manager_job_title,
  l.avatar as line_manager_avatar,
  a.kpa_id,
  c.kpa_name,
  a.kpi_id,
  b.kpi_name,
  a.evaluate,
  a.comments,
  a.link,
  a.status,
  a.created_at,
  a.updated_at
	FROM assessment a
	JOIN (
	SELECT employee_id, name, job_title, avatar FROM employees WHERE name LIKE CONCAT('%', keyword, '%')
	) e ON e.employee_id = a.employee_id
    JOIN (
	SELECT employee_id as line_manager_id, name as line_manager_name, job_title as line_manager_job_title, avatar FROM employees
	) l ON l.line_manager_id = a.line_manager_id
	JOIN (
	SELECT kpa_id, kpa_name FROM kpa
	) c ON c.kpa_id = a.kpa_id
	JOIN (
	SELECT kpi_id, kpi_name FROM kpi
	) b ON b.kpi_id = a.kpi_id
    order by updated_at desc;
end $$
delimiter ;





drop procedure if exists get_all_reviews_by_name;
delimiter $$
create procedure get_all_reviews_by_name(in keyword text)
begin
	select 
    r.review_id,
    r.assessment_id,
    e.employee_id,
    e.name,
    e.job_title as employee_job_title,
    e.avatar as employee_avatar,
    l.employee_id as line_manager_id,
    l.name as line_manager_name,
    l.job_title as line_manager_job_title,
    l.avatar as line_manager_avatar,
    a.kpa_id,
    a.kpa_name,
    i.kpi_id,
    i.kpi_name,
    r.employee_evaluate,
    r.employee_comments,
    r.employee_link,
    r.evaluate,
    r.comments,
    r.status,
    r.updated_at
    from 
    (select review_id, line_manager_id, assessment_id, employee_id, kpa_id, kpi_id,employee_evaluate, employee_comments, employee_link, evaluate, comments, status, updated_at from review ) r
    join 
    (select employee_id, name, job_title, avatar from employees WHERE name LIKE CONCAT('%', keyword, '%')) e on r.employee_id = e.employee_id 
    join 
    (select employee_id, name, job_title, avatar from employees) l on r.line_manager_id = l.employee_id
    join
    (select kpa_id, kpa_name from kpa) a on r.kpa_id = a.kpa_id
    join
    (select kpi_id, kpi_name from kpi) i on r.kpi_id = i.kpi_id
    order by updated_at desc;
end $$
delimiter ;
	
    




drop procedure if exists delete_kpa;
delimiter $$
create procedure delete_kpa(in kpaId int, in accountId int)
begin
	if accountId =1 then
	begin
		delete from kpa where kpa_id = kpaId;
		select 1;
	end;
	else select 0;
    end if;
end $$
delimiter ;





drop procedure if exists delete_kpi;
delimiter $$
create procedure delete_kpi(in kpiId int, in accountId int)
begin
	if accountId =1 then
	begin
		delete from kpi where kpi_id = kpiId;
		select 1;
	end;
	else select 0;
    end if;
end $$
delimiter ;