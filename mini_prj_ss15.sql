CREATE DATABASE Social_Network;
USE Social_Network;

CREATE TABLE Users(
	user_id int primary key auto_increment,
    username varchar(50) unique not null,
    password varchar(255) not null,
    email varchar(100) unique not null,
    created_at datetime default current_timestamp
);

CREATE TABLE Posts(
	post_id int primary key auto_increment,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references Users(user_id) on delete cascade
);

CREATE TABLE Comments(
	comment_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
	foreign key (user_id) references Users(user_id) on delete cascade,
    foreign key (post_id) references Posts(post_id) on delete cascade
);

CREATE TABLE Friends(
	user_id int not null,
    friend_id int not null,
    status varchar(20) not null check(status IN ('pending', 'accepted')),
	created_at datetime default current_timestamp,
	primary key (user_id, friend_id),
    foreign key (user_id) references Users(user_id) on delete cascade,
	foreign key (friend_id) references Users(user_id) on delete cascade
);

CREATE TABLE Likes(
	like_id int primary key auto_increment,
    user_id int not null,
    post_id int not null,
	created_at datetime default current_timestamp,
	unique key(post_id, user_id),
	foreign key (user_id) references Users(user_id) on delete cascade,
    foreign key (post_id) references Posts(post_id) on delete cascade
);

insert into users (username, password, email) values 
('nguyen van a', 'pass123', 'nguyenvana@example.com'),
('tran thi b', 'pass456', 'tranthib@example.com'),
('le van c', 'pass789', 'levanc@example.com'),
('pham thi d', 'secret1', 'phamthid@example.com'),
('hoang van e', 'secret2', 'hoangvane@example.com');

insert into posts (user_id, content) values 
(1, 'hom nay troi dep qua, di da bong thoi'),
(1, 'sql kho qua nhung ma vui'),
(2, 'tim dong doi di da bong chieu nay'),
(3, 'chuc mung nam moi ca nha'),
(4, 'review quan cafe moi o quan 1');

insert into comments (post_id, user_id, content) values 
(1, 2, 'dong y, thoi tiet tuyet voi'),
(1, 3, 'code o dau the ban'),
(2, 4, 'co len ban oi, sap xong roi'),
(3, 1, 'minh dang ky 1 slot nhe'),
(5, 2, 'gia ca the nao ban');

insert into likes (user_id, post_id) values 
(2, 1), -- b like bài của a
(3, 1), -- c like bài của a
(4, 1), -- d like bài của a
(1, 3), -- a like bài của c
(5, 5); -- e like bài của d

insert into friends (user_id, friend_id, status) values 
(1, 2, 'accepted'), -- a và b là bạn bè
(1, 3, 'pending'),  -- a gửi lời mời cho c (đang chờ)
(2, 4, 'accepted'), -- b và d là bạn bè
(3, 5, 'pending');  -- c gửi lời mời cho e (đang chờ)

-- F01: đăng ký thành viên
delimiter $$
create procedure sp_register_user(
    in p_username varchar(50),
    in p_password varchar(255),
    in p_email varchar(100)
)
begin
    declare v_count int default 0;

    -- kiểm tra username trùng
    select count(*) into v_count
    from users
    where username = p_username;

    if v_count > 0 then
        signal sqlstate '45000' set message_text = 'tên đã tồn tại';
    end if;

    -- kiểm tra email trùng
    select count(*) into v_count
    from users
    where email = p_email;

    if v_count > 0 then
        signal sqlstate '45000' set message_text = 'email đã dùng';
    end if;

    insert into users (username, password, email) values 
    (p_username, p_password, p_email);

    select 'đăng ký thành công' as message;
end$$
delimiter ;

-- F02: đăng bài viết 
delimiter $$
create procedure sp_create_post(
  in p_user_id int,
  in p_content text
)
begin
  declare v_exists int default 0;
  declare v_new_post_id int default 0;

  -- nếu có lỗi sql bất ngờ thì rollback và báo lỗi chung
  declare exit handler for sqlexception
  begin
    rollback;
    signal sqlstate '45000' set message_text = 'lỗi khi tạo bài viết, đã rollback';
  end;

  start transaction;

  -- 1) kiểm tra user tồn tại
  select count(*) into v_exists
  from users
  where user_id = p_user_id;

  if v_exists = 0 then
    rollback;
    signal sqlstate '45000' set message_text = 'người dùng không tồn tại';
  end if;

  -- 2) chèn bài viết
  insert into posts (user_id, content)
  values (p_user_id, p_content);

  set v_new_post_id = last_insert_id();

  commit;

  -- trả về thông báo và post_id 
  select 'tạo bài viết thành công' as message, v_new_post_id as post_id;
end$$
delimiter ;

-- thành công (user tồn tại)
call sp_create_post(1, 'bài viết mới từ user 1: hôm nay đi chơi!');
select * from posts where post_id = last_insert_id();
select * from post_log where post_id = last_insert_id();

-- lỗi (user không tồn tại)
call sp_create_post(99, 'bài viết thử lỗi');

-- F03: thích bài viết 
ALTER TABLE Posts
ADD like_count INT DEFAULT 0;
DELIMITER $$

-- thích bài viết 
CREATE TRIGGER trg_after_like
AFTER INSERT ON Likes
FOR EACH ROW
BEGIN
    UPDATE Posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END$$

DELIMITER ;

DELIMITER $$

-- xóa lượt thích
CREATE TRIGGER trg_after_unlike
AFTER DELETE ON Likes
FOR EACH ROW
BEGIN
    UPDATE Posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END$$

DELIMITER ;
-- thêm lượt thích
INSERT INTO Likes(user_id, post_id)
VALUES (2, 1);  -- like_count =1
-- xóa lượt thích
DELETE  FROM Likes 
WHERE user_id=2 AND post_id = 1; -- like_count =0
-- test số like
SELECT  * FROM Posts ;
-- F04: gửi lời mời kết bạn 
delimiter $$
create trigger trg_send_friend_request
after insert on friends
for each row
begin
    if new.status = 'pending' then
        insert into friend_log(user_id, friend_id, action)
        values (new.user_id, new.friend_id, 'send_request');
    end if;
end$$
delimiter ;

-- thao tác chạy
insert into friends(user_id, friend_id)
values (1, 2);

-- F05: hủy lời mời kết bạn 
delimiter $$
create trigger trg_cancel_friend_request
after delete on friends
for each row
begin
    if old.status = 'pending' then
        insert into friend_log(user_id, friend_id, action)
        values (old.user_id, old.friend_id, 'cancel_request');
    end if;
end$$
delimiter ;

-- thao tác chạy
delete from friends
where user_id = 1 and friend_id = 2;

-- F06: chấp nhận lời mời kết bạn 
DELIMITER $$

CREATE TRIGGER trg_accept_friend
BEFORE UPDATE ON Friends
FOR EACH ROW
BEGIN
    IF OLD.status <> 'pending' OR NEW.status <> 'accepted' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'lời mời đã được chấp nhận';
    END IF;
END $$

DELIMITER ;

-- chấp nhận kết bạn giữa 1 và 2 
UPDATE Friends
SET status = 'accepted'
WHERE user_id = 1 AND friend_id = 2;

-- kiểm tra 
select * from  Friends;
-- F07: xem thông tin người dùng 
create or replace view view_user_profile as
select 
    u.user_id, u.username, u.email, u.created_at as joined,
    count(distinct p.post_id) as posts,
    count(distinct case when f.status = 'accepted' then 1 end) as friends
from users u
left join posts p on u.user_id = p.user_id
left join friends f on u.user_id in (f.user_id, f.friend_id) and f.status = 'accepted'
group by u.user_id;

-- F08: xem bài viết theo từ khóa 
create fulltext index ft_posts_content on posts(content);

-- tạo index hỗ trợ join và order by
create index idx_posts_user_id on posts(user_id);
create index idx_posts_created_at on posts(created_at);

select p.post_id, u.username, p.content, p.created_at,
  match(p.content) against('di da bong' in natural language mode) as score
from posts p
join users u on p.user_id = u.user_id
where match(p.content) against('di da bong' in natural language mode)
order by score desc, p.created_at desc
limit 10;

-- F09: Báo cáo hoạt động người dùng 
CREATE VIEW view_user_activity AS
SELECT u.user_id, u.username,
       COUNT(DISTINCT p.post_id) posts,
       COUNT(DISTINCT l.post_id) likes
FROM users u
LEFT JOIN posts p ON u.user_id=p.user_id
LEFT JOIN likes l ON u.user_id=l.user_id
GROUP BY u.user_id;
-- F10: Gợi ý kết bạn 
DELIMITER $$

CREATE PROCEDURE sp_suggest_friends(IN p_user INT)
BEGIN
    SELECT DISTINCT f2.friend_id AS suggested_friend
    FROM friends f1
    JOIN friends f2 ON f1.friend_id = f2.user_id
    WHERE f1.user_id = p_user
      AND f2.friend_id <> p_user
      AND f2.friend_id NOT IN (
          SELECT friend_id FROM friends WHERE user_id=p_user
      );
END$$
DELIMITER ;
-- F11: Quản lý xóa bài viết
-- Tạo bảng lưu lịch sử bài viết bị xóa
create table deleted_posts_log (
    log_id int primary key auto_increment,
    post_id int,
    user_id int,
    content text,
    deleted_at datetime default current_timestamp
);

-- tạo trigger: tự động lưu bài viết vào log trước khi bị xóa vĩnh viễn
delimiter $$
drop trigger if exists tg_before_delete_post $$
create trigger tg_before_delete_post
before delete on posts
for each row
begin
    insert into deleted_posts_log (post_id, user_id, content)
    values (old.post_id, old.user_id, old.content);
end $$
delimiter ;

-- tạo procedure xóa bài viết 
delimiter $$
drop procedure if exists sp_delete_post $$
create procedure sp_delete_post(
    in p_post_id int
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate '45000' set message_text = 'lỗi: không thể xóa bài viết!';
    end;

    start transaction;
        -- kiểm tra bài viết có tồn tại không
        if not exists (select 1 from posts where post_id = p_post_id) then
            signal sqlstate '45000' set message_text = 'bài viết không tồn tại!';
        end if;

        -- thực hiện xóa
        delete from posts where post_id = p_post_id;

    commit;
end $$
delimiter ; 
-- Test xóa bài viết
call sp_delete_post(2);
-- kiểm tra log xem đã lưu chưa
select * from deleted_posts_log;

-- F12: Quản lý xóa tài khoản người dùng
delimiter $$
drop procedure if exists sp_delete_user $$
create procedure sp_delete_user(
    in p_user_id int
)
begin
    -- khai báo xử lý lỗi
    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate '45000' set message_text = 'lỗi: không thể xóa tài khoản!';
    end;

    start transaction;
        -- kiểm tra user có tồn tại không
        if not exists (select 1 from users where user_id = p_user_id) then
            signal sqlstate '45000' set message_text = 'người dùng không tồn tại!';
        end if;

        -- xóa người dùng
        -- toàn bộ posts, comments, likes, friends sẽ tự động bị xóa nhờ on delete cascade
        delete from users where user_id = p_user_id;

    commit;
end $$
delimiter ;
-- Test xóa user
call sp_delete_user(3);
-- kiểm tra bảng users
select * from users;

-- F13: cập nhật thông tin người dùng
delimiter $$
create procedure sp_update_user(
  in p_user_id int,
  in p_username varchar(50),
  in p_password varchar(255),
  in p_email varchar(100)
)
begin
  declare v_exists int default 0;
  declare v_conflict int default 0;

  -- bắt lỗi sql bất ngờ: rollback và báo lỗi
  declare exit handler for sqlexception
  begin
    rollback;
    signal sqlstate '45000' set message_text = 'lỗi hệ thống: cập nhật không thành công';
  end;

  start transaction;

  -- 1) kiểm tra user tồn tại
  select count(*) into v_exists from users where user_id = p_user_id;
  if v_exists = 0 then
    rollback;
    signal sqlstate '45000' set message_text = 'người dùng không tồn tại';
  end if;

  -- 2) nếu p_username khác null thì kiểm tra trùng
  if p_username is not null then
    select count(*) into v_conflict
    from users
    where username = p_username and user_id <> p_user_id;
    if v_conflict > 0 then
      rollback;
      signal sqlstate '45000' set message_text = 'tên đăng nhập đã được sử dụng';
    end if;
  end if;

  -- 3) nếu p_email khác null thì kiểm tra trùng và kiểm tra định dạng email
  if p_email is not null then
    select count(*) into v_conflict
    from users
    where email = p_email and user_id <> p_user_id;
    if v_conflict > 0 then
      rollback;
      signal sqlstate '45000' set message_text = 'email đã được sử dụng';
    end if;

    -- kiểm tra dạng email: có ký tự '@' và '.'
    if not (p_email like '%@%._%' or p_email like '%@%.%') then
      rollback;
      signal sqlstate '45000' set message_text = 'định dạng email không hợp lệ';
    end if;
  end if;

  -- 4) thực hiện cập nhật: chỉ cập nhật các trường không null
  update users
  set
    username = coalesce(p_username, username),
    password = coalesce(p_password, password),
    email = coalesce(p_email, email)
  where user_id = p_user_id;

  commit;

  -- trả thông báo đơn giản
  select 'cập nhật thông tin thành công' as message;
end$$
delimiter ;
-- cập nhật username và email
call sp_update_user(1, 'nguyenvana_new', null, 'nvnew@example.com');

-- chỉ đổi mật khẩu 
call sp_update_user(2, null, 'new_password', null);

-- F14: quản lý mối quan hệ bạn bè
delimiter $$
drop procedure if exists sp_manage_friend $$
create procedure sp_manage_friend(
  in p_user_id int,
  in p_friend_id int,
  in p_action varchar(20) 
)
begin
  declare v_exists_user int default 0;
  declare v_row_exists int default 0;
  declare v_status varchar(20);

  declare exit handler for sqlexception
  begin
    rollback;
    signal sqlstate '45000' set message_text = 'lỗi hệ thống: thao tác bạn bè không thành công';
  end;

  start transaction;

  -- kiểm tra user tồn tại
  select count(*) into v_exists_user from users where user_id = p_user_id;
  if v_exists_user = 0 then
    rollback;
    signal sqlstate '45000' set message_text = 'người dùng thực hiện không tồn tại';
  end if;

  select count(*) into v_exists_user from users where user_id = p_friend_id;
  if v_exists_user = 0 then
    rollback;
    signal sqlstate '45000' set message_text = 'người dùng đích không tồn tại';
  end if;

  -- không cho tự kết bạn
  if p_user_id = p_friend_id then
    rollback;
    signal sqlstate '45000' set message_text = 'không thể gửi lời mời cho chính mình';
  end if;

  -- xử lý theo action
  if p_action = 'send_request' then
    -- nếu đã có quan hệ thì xử lý tương ứng
    select count(*) into v_row_exists
    from friends
    where (user_id = p_user_id and friend_id = p_friend_id)
       or (user_id = p_friend_id and friend_id = p_user_id);

    if v_row_exists > 0 then
      -- kiểm tra nếu có lời mời ngược đang pending thì chấp nhận tự động
      select status into v_status
      from friends
      where user_id = p_friend_id and friend_id = p_user_id
      limit 1;

      if v_status = 'pending' then
        -- chấp nhận lời mời ngược
        update friends
        set status = 'accepted'
        where user_id = p_friend_id and friend_id = p_user_id;
        insert into friend_log(user_id, friend_id, action, note)
        values (p_friend_id, p_user_id, 'auto_accept', 'auto-accepted reverse pending request');
      else
        rollback;
        signal sqlstate '45000' set message_text = 'quan hệ đã tồn tại';
      end if;
    else
      -- tạo lời mời mới
      insert into friends(user_id, friend_id, status)
      values (p_user_id, p_friend_id, 'pending');
      insert into friend_log(user_id, friend_id, action)
      values (p_user_id, p_friend_id, 'send_request');
    end if;

  elseif p_action = 'accept' then
    -- chấp nhận: chỉ chấp nhận khi có lời mời từ friend_id -> user_id
    select count(*) into v_row_exists
    from friends
    where user_id = p_friend_id and friend_id = p_user_id and status = 'pending';

    if v_row_exists = 0 then
      rollback;
      signal sqlstate '45000' set message_text = 'không có lời mời để chấp nhận';
    end if;

    update friends
    set status = 'accepted'
    where user_id = p_friend_id and friend_id = p_user_id;

    insert into friend_log(user_id, friend_id, action)
    values (p_user_id, p_friend_id, 'accept_request');

  elseif p_action = 'cancel' then
    -- huỷ lời mời: chỉ người gửi mới huỷ được khi status = pending
    select count(*) into v_row_exists
    from friends
    where user_id = p_user_id and friend_id = p_friend_id and status = 'pending';

    if v_row_exists = 0 then
      rollback;
      signal sqlstate '45000' set message_text = 'không có lời mời đang chờ để huỷ';
    end if;

    delete from friends
    where user_id = p_user_id and friend_id = p_friend_id and status = 'pending';

    insert into friend_log(user_id, friend_id, action)
    values (p_user_id, p_friend_id, 'cancel_request');

  elseif p_action = 'reject' then
    -- từ chối: người nhận từ chối lời mời 
    select count(*) into v_row_exists
    from friends
    where user_id = p_friend_id and friend_id = p_user_id and status = 'pending';

    if v_row_exists = 0 then
      rollback;
      signal sqlstate '45000' set message_text = 'không có lời mời để từ chối';
    end if;

    delete from friends
    where user_id = p_friend_id and friend_id = p_user_id and status = 'pending';

    insert into friend_log(user_id, friend_id, action)
    values (p_user_id, p_friend_id, 'reject_request');

  elseif p_action = 'remove' then
    -- xóa quan hệ bạn bè (accepted)
    select count(*) into v_row_exists
    from friends
    where ((user_id = p_user_id and friend_id = p_friend_id) or (user_id = p_friend_id and friend_id = p_user_id))
      and status = 'accepted';

    if v_row_exists = 0 then
      rollback;
      signal sqlstate '45000' set message_text = 'không có quan hệ bạn bè để xóa';
    end if;

    delete from friends
    where ((user_id = p_user_id and friend_id = p_friend_id) or (user_id = p_friend_id and friend_id = p_user_id))
      and status = 'accepted';

    insert into friend_log(user_id, friend_id, action)
    values (p_user_id, p_friend_id, 'remove_friend');

  else
    rollback;
    signal sqlstate '45000' set message_text = 'hành động không hợp lệ';
  end if;

  commit;

  -- trả thông báo đơn giản
  select concat('thực hiện ', p_action, ' thành công') as message;
end$$
delimiter ;

-- gửi lời mời từ user 1 tới user 4
call sp_manage_friend(1, 4, 'send_request');

-- user 4 chấp nhận lời mời từ user 1
call sp_manage_friend(4, 1, 'accept');

-- user 1 huỷ lời mời đã gửi tới user 3
call sp_manage_friend(1, 3, 'cancel');

-- user 2 xóa quan hệ bạn bè với user 4
call sp_manage_friend(2, 4, 'remove');
