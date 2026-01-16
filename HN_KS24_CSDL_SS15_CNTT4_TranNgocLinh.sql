/*
 * DATABASE SETUP - SESSION 15 EXAM
 * Database: StudentManagement
 */

DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

-- =============================================
-- 1. TABLE STRUCTURE
-- =============================================

-- Table: Students
CREATE TABLE Students (
    StudentID CHAR(5) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    TotalDebt DECIMAL(10,2) DEFAULT 0
);

-- Table: Subjects
CREATE TABLE Subjects (
    SubjectID CHAR(5) PRIMARY KEY,
    SubjectName VARCHAR(50) NOT NULL,
    Credits INT CHECK (Credits > 0)
);

-- Table: Grades
CREATE TABLE Grades (
    StudentID CHAR(5),
    SubjectID CHAR(5),
    Score DECIMAL(4,2) CHECK (Score BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, SubjectID),
    CONSTRAINT FK_Grades_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT FK_Grades_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);

-- Table: GradeLog
CREATE TABLE GradeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID CHAR(5),
    OldScore DECIMAL(4,2),
    NewScore DECIMAL(4,2),
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. SEED DATA
-- =============================================

-- Insert Students
INSERT INTO Students (StudentID, FullName, TotalDebt) VALUES 
('SV01', 'Ho Khanh Linh', 5000000),
('SV03', 'Tran Thi Khanh Huyen', 0);

-- Insert Subjects
INSERT INTO Subjects (SubjectID, SubjectName, Credits) VALUES 
('SB01', 'Co so du lieu', 3),
('SB02', 'Lap trinh Java', 4),
('SB03', 'Lap trinh C', 3);

-- Insert Grades
INSERT INTO Grades (StudentID, SubjectID, Score) VALUES 
('SV01', 'SB01', 8.5), -- Passed
('SV03', 'SB02', 3.0); -- Failed

-- End of File

-- PHẦN A – CƠ BẢN
-- Câu 1 (TrTrigger - 2đ): Nhà trường yêu cầu điểm số (Score) nhập vào hệ thống phải luôn hợplệ (từ 0 đến 10). Hãy viết một TrTrigger có tên tg_CheckScore chạy trước khi thêm(BEFORE INSERTRT) dữ liệu vào bảng Grades.
delimiter //
create trigger tg_CheckScore
before insert on Grades
for each row
begin
	if New.Score < 0 then
		set New.Score = 0;
	elseif New.Score > 10 then
		set New.Score = 10;
	end if;
end //
delimiter ;

-- Câu 2 (Transaction - 2đ): Viết một đoạn script sử dụng Transaction để thêm một sinh viên mới. Yêu cầu đảm bảo tính trọn vẹn or Nothing" của dữ liệu:

start transaction;
insert into Students(StudentID,FullName) values
('SV02','Ha Bich Ngoc');
update Students
set TotalDebt = 5000000
where StudentID = 'SV02';
commit;

-- PHẦN B – KHÁ
-- Câu 3 (Trigger - 1.5đ): Để chống tiêu cực trong thi cử, mọi hành động sửa đổi điểm số cầnđược ghi lại. Hãy viết TrTrigger tên tg_LogGradeUpdate chạy sau khi cập nhật (AFTERUPDATATE) trên bảng Grades.

delimiter //
create trigger tg_LogGradeUpdate
after update on Grades
for each row
begin
	if old.Score <> new.Score then
		insert into GradeLog(StudentID,OldScore,NewScore,ChangeDate) 
        values(old.StudentID,old.Score,new.Score,NOW());
	end if;
end //
delimiter ;

-- Câu 4 (Transaction & Procedure cơ bản - 1.5đ): Viết một Stored Procedure đơn giản tên sp_PayTuTuition thực hiện việc đóng học phí cho sinh viên với số tiền2,000,000.
delimiter //
create procedure sp_PayTuition(
	in p_StudentID char(5)
)
begin
	start transaction;
	update Students
    set TotalDebt= TotalDebt -2000000
    where StudentID = p_StudentID;
    if (select TotalDebt from Students where StudentID = p_StudentID ) < 0 then
		rollback;
	else
		commit;
	end if;
end //
delimiter ;
call sp_PayTuition('SV01');
-- Câu 5 (Trigger nâng cao - 1.5đ): Viết TrTrigger tên tg_PreventPassUpdate.

delimiter //
create trigger tg_PreventPassUpdate
before update on Grades
for each row
begin 
	if old.Score >= 4.0 then
	signal sqlstate '45000'
	set message_text = 'Sinh vien da qua mon, khong duoc phep sua diem';
		end if;
end //
delimiter ;

-- Câu 6 (Stored Procedure & TrTransaction - 1.5đ): ViViết một Stored Procedure tênsp_DeleteStudentGrade nhận vào \
delimiter //
create procedure sp_DeleteStudentGrade (
    in p_StudentID char(5),
    in p_SubjectID char(5)
)
begin
    declare v_Score decimal(4,2);

    start transaction;

    select Score into v_Score
    from Grades
    where StudentID = p_StudentID and SubjectID = p_SubjectID;

    insert into GradeLog (StudentID, OldScore, NewScore, ChangeDate)
    values (p_StudentID, v_Score, null, NOW());

    delete from Grades
    where StudentID = p_StudentID and SubjectID = p_SubjectID;

    if row_count() = 0 then
        rollback;
    else
        commit;
    end if;
end;
DELIMITER ;
