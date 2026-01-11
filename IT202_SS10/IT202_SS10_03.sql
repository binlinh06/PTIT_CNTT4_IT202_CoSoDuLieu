
-- 2
EXPLAIN ANALYZE
SELECT *
FROM users
WHERE hometown = 'Hà Nội';
-- 3
CREATE INDEX idx_hometown
ON users(hometown);
SHOW INDEX FROM users;

-- 4
EXPLAIN ANALYZE
SELECT *
FROM users
WHERE hometown = 'Hà Nội';

-- 5
DROP INDEX idx_hometown ON users;
SHOW INDEX FROM users;
