-- 1
use social_network_pro;
DROP PROCEDURE IF EXISTS CalculateBonusPoints;
delimiter //
create procedure CalculateBonusPoints(
	in p_user_id int,
    inout p_bonus_points int 
)
begin
	declare TotalPost int ;
    select count(*)
    into TotalPost from posts 
    where user_id = p_user_id;
    if TotalPost >= 20 then 
		set p_bonus_points = p_bonus_points + 100;
	elseif TotalPost>= 10 then
		set p_bonus_points = p_bonus_points + 50;
	end if;
end //
delimiter ;
set @p_bonus_points = 100;
call CalculateBonusPoints(1,@p_bonus_points);
select @p_bonus_points as bonus_points_after_calculation;