-- 1
USE social_network_pro;

-- 2
CREATE INDEX idx_user_gender
ON users(gender);

-- 3

CREATE OR REPLACE VIEW view_popular_posts AS
SELECT
    p.post_id,
    u.username,
    p.content,
    COUNT(DISTINCT l.like_id) AS like_count,
    COUNT(DISTINCT c.comment_id) AS comment_count
FROM posts p
JOIN users u ON u.user_id = p.user_id
LEFT JOIN likes l ON l.post_id = p.post_id
LEFT JOIN comments c ON c.post_id = p.post_id
GROUP BY
    p.post_id,
    u.username,
    p.content;


-- 4
SELECT *
FROM view_popular_posts;

-- 5
SELECT
    post_id,
    username,
    content,
    (like_count + comment_count) AS total_interaction
FROM view_popular_posts
WHERE (like_count + comment_count) > 10
ORDER BY total_interaction DESC;
