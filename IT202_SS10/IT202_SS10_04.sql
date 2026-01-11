use social_network_pro;
-- 2
select * from Users;
select * from Posts;
EXPLAIN ANALYZE
select post_id,content,created_at from Posts
where user_id = 1 and created_at BETWEEN '2026-01-01' AND '2026-12-31';

create index idx_created_at_user_id 
on Posts(created_at ,user_id);


-- 3 
EXPLAIN ANALYZE
select user_id,username,email from Users
where email = 'an@gmail.com';

create index idx_email 
on Users(email);

-- 4
DROP INDEX idx_created_at_user_id ON posts;
DROP INDEX idx_email ON users;

SHOW INDEX FROM posts;
SHOW INDEX FROM users;
