-- 1
USE social_network_pro;

-- 2
CREATE INDEX idx_user_gender
ON users(gender);
SHOW INDEX FROM users;

-- 3
CREATE OR REPLACE VIEW view_user_activity AS
SELECT
    u.user_id,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM users u
LEFT JOIN posts p ON p.user_id = u.user_id
LEFT JOIN comments c ON c.user_id = u.user_id
GROUP BY u.user_id;

-- 4
SELECT *
FROM view_user_activity;

-- 5
SELECT
    u.user_id,
    u.username,
    u.gender,
    v.total_posts,
    v.total_comments
FROM view_user_activity v
JOIN users u ON u.user_id = v.user_id
WHERE v.total_posts > 5
  AND v.total_comments > 20
ORDER BY v.total_comments DESC
LIMIT 5;
