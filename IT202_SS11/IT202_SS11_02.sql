-- 1
use social_network_pro;
DROP PROCEDURE IF EXISTS CalculatePostLikes;
-- 2
delimiter //
create procedure CalculatePostLikes(
	IN p_post_id int,
    OUT total_likes int
)
begin
	select * from likes;
	select count(*) into total_likes 
    from likes
    where post_id = p_post_id;
end //
delimiter ;

call CalculatePostLikes(1,@total_likes);
SELECT @total_likes AS total_likes;