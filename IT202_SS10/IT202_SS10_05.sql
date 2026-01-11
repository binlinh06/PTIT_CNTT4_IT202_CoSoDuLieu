use social_network_pro;

create index idx_hometown on Users(hometown);
show index from Users;
EXPLAIN ANALYZE
select u.* ,p.post_id ,p.content  from Users u
join Posts p on p.user_id = u.user_id
where u.hometown = 'Hà Nội'
order by u.username desc
limit 10;
