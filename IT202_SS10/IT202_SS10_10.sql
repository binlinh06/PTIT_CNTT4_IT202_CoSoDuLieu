-- 1
USE social_network_pro;

-- 2
CREATE INDEX idx_user_username
ON users(username);

-- 3
CREATE VIEW view_user_activity_2 AS
SELECT 
    u.user_id,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT 
        CASE 
            WHEN f.status = 'accepted' THEN 
                IF(f.user_id = u.user_id, f.friend_id, f.user_id)
        END
    ) AS total_friends
FROM users u
LEFT JOIN posts p 
    ON u.user_id = p.user_id
LEFT JOIN friends f
    ON u.user_id = f.user_id 
    OR u.user_id = f.friend_id
GROUP BY u.user_id;

-- 4
SELECT * FROM view_user_activity_2;

-- 5
SELECT 
    u.full_name,
    v.total_posts,
    v.total_friends,

    -- Mô tả số bạn bè
    CASE
        WHEN v.total_friends > 5 THEN 'Nhiều bạn bè'
        WHEN v.total_friends BETWEEN 2 AND 5 THEN 'Vừa đủ bạn bè'
        ELSE 'Ít bạn bè'
    END AS friend_description,

    -- Điểm hoạt động bài viết
    CASE
        WHEN v.total_posts > 10 THEN v.total_posts * 1.1
        WHEN v.total_posts BETWEEN 5 AND 10 THEN v.total_posts
        ELSE v.total_posts * 0.9
    END AS post_activity_score

FROM view_user_activity_2 v
JOIN users u 
    ON v.user_id = u.user_id
WHERE v.total_posts > 0
ORDER BY v.total_posts DESC;
