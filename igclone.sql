-- =====================================================
-- Instagram Clone SQL Project Queries
-- By: Aditya Chaudhary
-- =====================================================

-- =====================================================
-- Query 1: Find the 5 oldest users on the platform
-- =====================================================
SELECT 
    username, created_at
FROM users
ORDER BY created_at ASC
LIMIT 5;


-- =====================================================
-- Query 2: Identify users who have never posted a photo
-- =====================================================
SELECT 
    u.user_id, 
    u.username
FROM users u
LEFT JOIN photos p ON u.user_id = p.user_id
WHERE p.user_id IS NULL;


-- =====================================================
-- Query 3: Find the most liked photo and its owner
-- =====================================================
SELECT 
    p.photo_id, 
    u.username, 
    COUNT(l.like_id) AS total_likes
FROM photos p
JOIN likes l ON p.id = l.photo_id
JOIN users u ON p.user_id = u.user_id
GROUP BY p.photo_id, u.username
ORDER BY total_likes DESC
LIMIT 1;


-- =====================================================
-- Query 4: Calculate the average number of posts per user
-- =====================================================
SELECT 
    ROUND(COUNT(p.id) / COUNT(DISTINCT u.user_id), 2) AS avg_posts_per_user
FROM users u
LEFT JOIN photos p ON u.user_id = p.user_id;


-- =====================================================
-- Query 5: Find the top 5 most used hashtags
-- =====================================================
SELECT 
    t.tag_name, 
    COUNT(pt.photo_id) AS usage_count
FROM tags t
JOIN photo_tags pt ON t.tag_id = pt.tag_id
GROUP BY t.tag_name
ORDER BY usage_count DESC
LIMIT 5;


-- =====================================================
-- Query 6: Calculate the average engagement rate (likes + comments) per post for each user
-- =====================================================
SELECT 
    u.user_id,
    u.username,
    ROUND(AVG(post_engagement.engagement), 2) AS avg_engagement_rate
FROM users u
JOIN (
    SELECT 
        p.user_id,
        p.id AS photo_id,
        (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS engagement
    FROM photos p
    LEFT JOIN likes l ON p.id = l.photo_id
    LEFT JOIN comments c ON p.id = c.photo_id
    GROUP BY p.id, p.user_id
) AS post_engagement
ON u.user_id = post_engagement.user_id
GROUP BY u.user_id, u.username
ORDER BY avg_engagement_rate DESC;


-- =====================================================
-- Query 7: Identify users who liked every single photo
-- =====================================================
SELECT 
    u.user_id, 
    u.username
FROM users u
WHERE NOT EXISTS (
    SELECT p.id
    FROM photos p
    WHERE NOT EXISTS (
        SELECT 1 
        FROM likes l 
        WHERE l.user_id = u.user_id 
          AND l.photo_id = p.id
    )
);


-- =====================================================
-- Query 8: Find inactive users (no likes, comments, or posts)
-- =====================================================
SELECT 
    u.user_id, 
    u.username
FROM users u
LEFT JOIN photos p ON u.user_id = p.user_id
LEFT JOIN likes l ON u.user_id = l.user_id
LEFT JOIN comments c ON u.user_id = c.user_id
WHERE p.id IS NULL 
  AND l.like_id IS NULL 
  AND c.comment_id IS NULL;


-- =====================================================
-- Query 9: Are there correlations between user activity levels and content type?
-- (e.g., number of likes/comments across photos vs reels)
-- =====================================================
SELECT 
    p.content_type,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY p.content_type;


-- =====================================================
-- Query 10: Find the most active users (based on likes + comments given)
-- =====================================================
SELECT 
    u.user_id,
    u.username,
    (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS total_activity
FROM users u
LEFT JOIN likes l ON u.user_id = l.user_id
LEFT JOIN comments c ON u.user_id = c.user_id
GROUP BY u.user_id, u.username
ORDER BY total_activity DESC
LIMIT 10;
