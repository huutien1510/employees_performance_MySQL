USE employees_performance;

-- ============================================================================
-- 🚀🚀🚀 TRIGGER: INSERT manage_info check 1 nhân viên/1 sếp/1 thời điểm 🚀🚀🚀
-- ============================================================================
drop trigger if exists before_insert_manage_info_check_overlap;
delimiter //
CREATE TRIGGER before_insert_manage_info_check_overlap
BEFORE INSERT ON manage_info
FOR EACH ROW
BEGIN
	DECLARE overlap_count INT;
	
	SELECT COUNT(*)
	INTO overlap_count
	FROM manage_info
	WHERE (employee_id = NEW.employee_id)
	AND (
        (NEW.end_date IS NULL OR NEW.end_date >= start_date)
        AND (end_date IS NULL OR end_date >= NEW.start_date)
    );
		
		IF overlap_count > 0 THEN
		SIGNAL SQLSTATE '10000' 
		SET message_text = 'Nhân viên trùng lặp/ sai khoảng thời gian với quan hệ quản lý';
		END IF;
END//
delimiter ;



-- ============================================================================
-- 🚀🚀🚀 TRIGGER: UPDATE manage_info check 1 nhân viên/1 sếp/1 thời điểm 🚀🚀🚀
-- ============================================================================
drop trigger if exists before_update_manage_info_check_overlap;
delimiter //
CREATE TRIGGER before_update_manage_info_check_overlap
BEFORE UPDATE ON manage_info
FOR EACH ROW
BEGIN
	DECLARE overlap_count INT;
	
	SELECT COUNT(*)
	INTO overlap_count
	FROM manage_info
	WHERE (employee_id = NEW.employee_id)
	AND (
        (NEW.end_date IS NULL OR NEW.end_date >= start_date)
        AND (end_date IS NULL OR end_date >= NEW.start_date)
    );
		
		IF overlap_count > 0 THEN
		SIGNAL SQLSTATE '10000' 
		SET message_text = 'Nhân viên trùng lặp/ sai khoảng thời gian với quan hệ quản lý';
		END IF;
END//
delimiter ;



-- =====================================================================================
-- 🚀🚀🚀 TRIGGER: trước khi DELETE 1 assessment => delete review cua assessment 🚀🚀🚀
-- =====================================================================================
drop trigger if exists delete_review_before_delete_assessment;
delimiter //
create trigger delete_review_before_delete_assessment
before delete on assessment
for each row
begin
	delete 
    from review
    where review.assessment_id = old.assessment_id;
end //
delimiter ;



-- =====================================================================================
-- 🚀🚀🚀 TRIGGER: insert vào review sau khi thêm assessment 🚀🚀🚀
-- =====================================================================================
drop trigger if exists insert_review_after_insert_assessment;
delimiter $$
create trigger insert_review_after_insert_assessment
after insert on assessment
for each row
begin
	insert into review(assessment_id, employee_id,line_manager_id,kpi_id,kpa_id,employee_evaluate,employee_comments,employee_link,status,created_at,updated_at)
	values (new.assessment_id, new.employee_id,new.line_manager_id,new.kpi_id,new.kpa_id,new.evaluate,new.comments,new.link,new.status,new.created_at,new.updated_at);
end $$
delimiter ;




-- =====================================================================================
-- 🚀🚀🚀 TRIGGER: update review sau khi update assessment 🚀🚀🚀
-- =====================================================================================
drop trigger if exists update_review_after_update_assessment;
delimiter $$
create trigger update_review_after_update_assessment
after update on assessment
for each row
begin
	update review
    set employee_id = new.employee_id,
    line_manager_id = new.line_manager_id,
    kpi_id = new.kpi_id,
    kpa_id = new.kpa_id,
    employee_evaluate = new.evaluate,
    employee_comments = new.comments,
    employee_link = new.link,
    status = new.status
    where assessment_id = new.assessment_id;
end $$
delimiter ;



-- -- =====================================================================================
-- -- 🚀🚀🚀 TRIGGER: cập nhật status của review và asessment đồng bộ 🚀🚀🚀
-- -- =====================================================================================
-- delimiter $$
-- create trigger update_status_assessment_after_update_review
-- after update on review
-- for each row
-- begin
-- 	update assessment
--     set status = "reviewed"
--     where assessment_id = old.assessment_id;
-- end $$
-- delimiter ;















