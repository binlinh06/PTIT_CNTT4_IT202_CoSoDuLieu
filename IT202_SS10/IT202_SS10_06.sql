-- 1
use social_network_pro;
select * from Posts;

-- 2
create or replace view view_users_summary 
as 
select u.user_id ,u.username ,count(p.post_id) as 'total_posts'
from Users u
join Posts p on p.user_id = u.user_id
group by u.user_id;

select * from view_users_summary;

-- 3
create or replace view view_users_summary 
as 
select u.user_id ,u.username ,count(p.post_id) as 'total_posts'
from Users u
join Posts p on p.user_id = u.user_id
group by u.user_id
having count(p.post_id) > 5;
