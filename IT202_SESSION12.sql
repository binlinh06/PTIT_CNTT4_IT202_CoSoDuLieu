drop database mini_project_social_network;
create database mini_project_social_network;
use mini_project_social_network;

create table Users(
	user_id int primary key,
	username varchar(50) unique not null,
	password varchar(255) not null,
	email varchar(100) unique not null,
	created_at datetime default current_timestamp
);

create table Posts(
	post_id int primary key,
    user_id int,
    content text not null,
	created_at datetime default current_timestamp,
    foreign key(user_id) references Users(user_id)
);
create table Comments(
	comment_id int primary key,
    post_id int,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key(post_id) references Posts(post_id),
    foreign key(user_id) references Users(user_id)
);
create table Friends (
    user_id int,
    friend_id int,
    status varchar(20) check (status in ('pending','accepted')),
    foreign key (user_id) references Users(user_id),
    foreign key (friend_id) references Users(user_id)
);

create table Likes(
	user_id int,
	post_id int,
    foreign key(user_id) references Users(user_id),
    foreign key(post_id) references Posts(post_id)
);

-- Bài 1. Quản lý người dùng
-- Chức năng mô phỏng: Đăng ký tài khoản
-- Thêm người dùng mới
-- Hiển thị danh sách người dùng.
insert into Users (user_id, username, password, email) values
(1, 'an', '123', 'an@gmail.com'),
(2, 'binh', '123', 'binh@gmail.com'),
(3, 'cuong', '123', 'cuong@gmail.com'),
(4, 'duy', '123', 'duy@gmail.com'),
(5, 'hoa', '123', 'hoa@gmail.com'),
(6, 'khanh', '123', 'khanh@gmail.com'),
(7, 'linh', '123', 'linh@gmail.com'),
(8, 'minh', '123', 'minh@gmail.com'),
(9, 'nam', '123', 'nam@gmail.com'),
(10, 'phuong', '123', 'phuong@gmail.com');

select * from Users;

-- Bài 2. Hiển thị thông tin công khai bằng VIEW
-- Chức năng mô phỏng: Trang hồ sơ công khai
-- Yêu cầu
-- Tạo View vw_public_users chỉ hiển thị:
-- user_id, username, created_at.
-- Thực hiện:
-- SELECT từ View
-- So sánh với SELECT trực tiếp từ bảng Users.
-- Giải thích:
-- Lợi ích bảo mật của View.

create or replace view vw_public_users as  
select user_id, username,created_at from Users;
select * from  vw_public_users;

-- Bài 3. Tối ưu tìm kiếm người dùng bằng INDEX
-- Chức năng mô phỏng: Tìm kiếm bạn bè
-- Yêu cầu
-- Tạo Index cho:
-- username trong bảng Users.
-- Viết truy vấn:
-- Tìm user theo username.
-- So sánh:
-- Truy vấn có Index
-- Truy vấn không Index (mô tả lý thuyết).
-- => Sau mức Trung bình, sinh viên đã xây dựng được:
-- Chức năng đăng ký – xem hồ sơ – tìm kiếm người dùng
create index idx_users_username on Users(username);

-- Bài 4. Quản lý bài viết bằng Stored Procedure
-- Chức năng mô phỏng: Đăng bài viết
-- Yêu cầu
-- Viết Procedure sp_create_post:
-- Tham số IN p_user_id, IN p_content.
-- Kiểm tra:
-- User tồn tại mới cho phép đăng bài.
-- Gọi Procedure bằng CALL.
DELIMITER $$
create procedure sp_create_post(
    in p_user_id int,
    in p_content text
)
begin
    declare v_post_id INT;

    -- kiểm tra user tồn tại
    if not exists (select 1 from Users where user_id = p_user_id) then
        signal sqlstate '45000'
        set message_text = 'User không tồn tại';
    else
        -- sinh post_id mới
       select ifnull(max(post_id), 0) + 1
        into v_post_id
        from Posts;

        -- insert bài viết
        insert into Posts(post_id, user_id, content)
        values (v_post_id, p_user_id, p_content);
    end if;
end $$
DELIMITER ;
call sp_create_post(1,'Bài viết đầu tiên');
select * from Posts;
drop procedure sp_create_post;

-- Bài 5. Hiển thị News Feed bằng VIEW
-- Chức năng mô phỏng: Trang chủ mạng xã hội
-- Yêu cầu
-- Tạo View vw_recent_posts:
-- Lấy bài viết trong 7 ngày gần nhất.
-- Viết truy vấn:
-- Hiển thị danh sách bài viết mới nhất.
create or replace view vw_recent_posts as 
select * from Posts 
where created_at >= date_sub(now(),interval 7 day);
select * from vw_recent_posts;

-- Bài 6. Tối ưu truy vấn bài viết
-- Chức năng mô phỏng: Xem bài viết của tôi
-- Yêu cầu
-- Tạo:
-- Index cho Posts.user_id
-- Composite Index (user_id, created_at).
-- Viết truy vấn:
-- Lấy danh sách bài viết của 1 user theo thời gian giảm dần.
-- Phân tích:
-- Vai trò của Composite Index.
create index idx_posts_user on Posts(user_id);
create index idx_posts_user_created on Posts(user_id, created_at);
select * from Posts
where user_id = 1
order by created_at desc;

-- Bài 7. Thống kê hoạt động bằng Stored Procedure
-- Chức năng mô phỏng: Trang thống kê cá nhân
-- Yêu cầu
-- Viết Procedure sp_count_posts:
-- IN p_user_id
-- OUT p_total.
-- Gọi Procedure và hiển thị kết quả.
-- => Sau mức Khá, sinh viên đã xây dựng được:
-- Chức năng đăng bài – xem news feed – xem thống kê cá nhân

DELIMITER $$
create procedure sp_count_posts(
    in p_user_id int,
    out p_total int
)
begin
    select count(*) into p_total
    from Posts
    where user_id = p_user_id;
end $$
DELIMITER ;
call sp_count_posts(1, @total);
select @total;

-- Bài 8. Kiểm soát dữ liệu bằng View WITH CHECK OPTION
-- Chức năng mô phỏng: Quản trị người dùng
-- Yêu cầu
-- Tạo View vw_active_users có:
-- Điều kiện lọc user đang hoạt động.
-- Áp dụng:
-- WITH CHECK OPTION.
-- Thực hiện:
-- INSERT / UPDATE thông qua View
-- Kiểm tra dữ liệu bị từ chối khi không thỏa điều kiện.
create or replace view vw_active_users as
select * from Users
where username is not null
with check option;


-- Bài 9. Quản lý kết bạn bằng Stored Procedure
-- Chức năng mô phỏng: Gửi lời mời kết bạn
-- Yêu cầu
-- Viết Procedure sp_add_friend:
-- IN p_user_id
-- IN p_friend_id.
-- Kiểm tra:
-- Không cho kết bạn với chính mình.
-- Sử dụng:
-- IF / ELSE.
DELIMITER $$
create procedure sp_add_friend(
    in p_user_id int,
    in p_friend_id int
)
begin
    if p_user_id = p_friend_id then
        signal sqlstate '45000'
        set message_text = 'Không thể kết bạn với chính mình';
    else
        insert into Friends(user_id, friend_id, status)
        values(p_user_id, p_friend_id, 'pending');
    end if;
end $$
DELIMITER ;

-- Bài 10. Gợi ý bạn bè bằng Procedure nâng cao
-- Chức năng mô phỏng: Gợi ý bạn bè
-- Yêu cầu
-- Viết Procedure sp_suggest_friends:
-- IN p_user_id
-- INOUT p_limit.
-- Áp dụng:
-- Biến
-- IF / ELSE
-- WHILE.
-- Trả về:
-- Danh sách gợi ý bạn bè.

DELIMITER $$
create procedure sp_suggest_friends(
    in p_user_id int,
    inout p_limit int
)
begin
    select u.user_id, u.username
    from users u
    where u.user_id != p_user_id
    limit p_limit;
end $$
DELIMITER ;


-- Bài 11. Thống kê tương tác nâng cao
-- Chức năng mô phỏng: Bảng xếp hạng
-- Yêu cầu
-- Viết truy vấn:
-- Top 5 bài viết nhiều lượt thích nhất.
-- Tạo View:
-- vw_top_posts.
-- Tạo Index:
-- Cho Likes.post_id.
-- => Sau mức Giỏi, sinh viên đã xây dựng được:
-- Chức năng kết bạn – gợi ý bạn bè – quản trị dữ liệu – bảng xếp hạng
create index idx_likes_post on likes(post_id);
create or replace view vw_top_posts as
select post_id, count(*) as total_likes
from likes
group by post_id
order by total_likes desc
limit 5;
select * from vw_top_posts;

-- BÀI 12. QUẢN LÝ BÌNH LUẬN
-- Chức năng mô phỏng
-- Người dùng bình luận vào bài viết.
-- Yêu cầu
-- Stored Procedure thêm bình luận:
-- Viết Procedure sp_add_comment:
-- Tham số:
-- IN p_user_id
-- IN p_post_id
-- IN p_content
-- Chức năng:
-- Kiểm tra:
-- User tồn tại
-- Post tồn tại
-- Nếu hợp lệ → thêm bình luận.
-- Nếu không → thông báo lỗi.
-- Bắt buộc dùng:
-- DECLARE
-- IF / ELSE.
-- View hiển thị bình luận
-- Tạo View vw_post_comments:
-- Hiển thị:
-- Nội dung bình luận
-- Tên người bình luận
-- Thời gian.
DELIMITER $$
create procedure sp_add_comment(
    in p_user_id int,
    in p_post_id int,
    in p_content text
)
begin
    if not exists (select 1 from Users where user_id = p_user_id) then
        signal sqlstate '45000' set message_text = 'User không tồn tại';
    elseif not exists (select 1 from Posts where post_id = p_post_id) then
        signal sqlstate '45000' set message_text = 'Post không tồn tại';
    else
        insert into comments(user_id, post_id, content)
        values (p_user_id, p_post_id, p_content);
    end if;
end $$
DELIMITER ;

create or replace view vw_post_comments as
select c.content, u.username, c.created_at
from comments c
join users u on c.user_id = u.user_id;

-- BÀI 13. QUẢN LÝ LƯỢT THÍCH
-- Chức năng mô phỏng: Người dùng thích bài viết.
-- Stored Procedure ghi nhận lượt thích
-- Viết Procedure sp_like_post:
-- Tham số:
-- IN p_user_id
-- IN p_post_id
-- Chức năng:
-- Kiểm tra: User đã thích post chưa.
-- Nếu chưa → thêm vào Likes.
-- Nếu rồi → không cho thêm trùng.
-- View thống kê lượt thích
-- Tạo View vw_post_likes:
-- Hiển thị:
-- post_id
-- Số lượt thích (COUNT(*)).

DELIMITER $$
create procedure sp_like_post(
    in p_user_id int,
    in p_post_id int
)
begin
    if exists (
        select 1 from Likes
        where user_id = p_user_id and post_id = p_post_id
    ) then
       signal sqlstate '45000'
        set message_text = 'Đã thích bài viết';
    else
        insert into Likes(user_id, post_id)
        values (p_user_id, p_post_id);
    end if;
end $$
DELIMITER ;

create or replace view vw_post_likes as
select post_id, count(*) as total_likes
from Likes
group by post_id;


-- Bài 14. TÌM KIẾM NGƯỜI DÙNG & BÀI VIẾT
-- Chức năng mô phỏng
-- Chức năng tìm kiếm trong mạng xã hội.
-- Yêu cầu
-- viết Stored Procedure có tên sp_search_social với các tham số:
-- p_option INT
-- p_keyword VARCHAR(100)
-- Trong đó:
-- Nếu p_option = 1 → tìm người dùng theo username.
-- Nếu p_option = 2 → tìm bài viết theo content.
-- Nếu giá trị khác → trả về thông báo lỗi.
-- Procedure phải sử dụng:
-- Cấu trúc điều kiện IF / ELSEIF / ELSE.
-- Hãy viết lệnh CALL để:
-- Tìm người dùng có username chứa từ "an".
-- Tìm bài viết có nội dung chứa từ "database".
-- => Sau mức Xuất Sắc, sinh viên đã xây dựng được:
-- Chức năng Quản lý bình luận – Quản lý lượt thích – Tìm kiếm


DELIMITER $$
create procedure sp_search_social(
    in p_option int,
    in p_keyword varchar(100)
)
begin
    if p_option = 1 then
        select * from Users
        where username like concat('%', p_keyword, '%');
    elseif p_option = 2 then
        select * from Posts
        where content like concat('%', p_keyword, '%');
    else
        signal sqlstate '45000'
        set message_text = 'Option không hợp lệ';
    end if;
end $$
DELIMITER ;
call sp_search_social(1, 'an');
call sp_search_social(2, 'database');
