
-- What SQL function can we use to fill in NULL values?

SELECT uid, COALESCE(device, '0') AS device
FROM activity;


-- What are the start and end dates of the experiment?
SELECT MIN(join_dt) AS experiment_start_date
FROM groups;

--the experiment end date:
SELECT MAX(join_dt) AS experiment_end_date
FROM groups;

-- Start and End Date
SELECT
    MIN(dt) AS start_date,
    MAX(dt) AS end_date
FROM
    activity;


-- How many total users were in the experiment?
SELECT COUNT(uid) AS total_users
FROM groups;




-- How many users were in the control and treatment groups?

SELECT "group", COUNT(DISTINCT uid) AS total_users
FROM groups
GROUP BY "group";

-- What was the conversion rate of all users?

-- SELECT COUNT(DISTINCT uid) as count_id from activity
--SELECT COUNT(DISTINCT id) AS conversion_rate FROM users;

SELECT
    (SELECT COUNT(DISTINCT uid) FROM activity) * 100.0 /
    (SELECT COUNT(DISTINCT id) FROM users) AS conversion_rate;


--What is the user conversion rate for the control and treatment groups?
SELECT
    g."group", COUNT(DISTINCT g.uid), COUNT(DISTINCT a.uid),
    COUNT(DISTINCT CASE WHEN a.spent > 0 THEN a.uid END) * 100.0 / COUNT(DISTINCT u.id) AS conversion_rate
FROM groups g
JOIN users u ON g.uid = u.id
LEFT JOIN activity a ON u.id = a.uid
GROUP BY g."group";

--9 What is the average amount spent per user for the control and treatment groups, including users who did not convert?
SELECT
    g."group", COUNT(DISTINCT g.uid),
    ROUND(AVG(COALESCE(a.spent, 0)), 3) / 100 AS avg_spent_per_user
FROM groups g
JOIN users u ON g.uid = u.id
LEFT JOIN activity a ON u.id = a.uid
GROUP BY g."group";

---------

SELECT
    u.id,
    u.country,
    u.gender,
    a.device,
    g.group,
    CASE WHEN a.uid IS NOT NULL THEN 'Converted' ELSE 'Not Converted' END AS conversion_status,
    COALESCE(SUM(a.spent), 0) AS total_spent
FROM
    users u
LEFT JOIN
    activity a ON u.id = a.uid
LEFT JOIN
    groups g ON g.uid = u.id
GROUP BY
    u.id, u.country, u.gender, a.device, g.group, conversion_status
ORDER BY
    u.id;
    
-- Selecting User Purchase Activity Information
SELECT a.uid, a.dt, a.device, SUM(a.spent) AS total_spent
FROM activity a
GROUP BY a.uid, a.dt, a.device;

-------------------
SELECT *
FROM users
inner JOIN activity ON users.id = activity.uid;


-------------------


SELECT
    u.id AS user_id,
    u.country,
    u.gender,
    g.group,
   -- g.group AS test_group,
    g.join_dt AS test_join_date,
    g.device AS test_device,
    a.dt AS purchase_date,
    a.device AS purchase_device,
    a.spent
FROM users u
LEFT JOIN groups g ON u.id = g.uid
LEFT JOIN activity a ON u.id = a.uid;


SELECT u.id AS user_id,
       u.country,
       u.gender,
       a.dt AS purchase_date,
       a.device AS purchase_device,
       a.spent
FROM users u
LEFT JOIN activity a ON u.id = a.uid;



WITH CombinedData AS (
    SELECT
        u.id AS user_id,
        u.country,
        u.gender,
        g.group,
        g.join_dt AS test_join_date,
        g.device AS test_device,
        a.dt AS purchase_date,
        a.device AS purchase_device,
        a.spent,
        ROW_NUMBER() OVER (PARTITION BY u.id, a.spent ORDER BY u.id) AS row_num
    FROM users u
    LEFT JOIN groups g ON u.id = g.uid
    LEFT JOIN activity a ON u.id = a.uid
)
SELECT
    user_id,
    country,
    gender,
    "group",
    test_join_date,
    test_device,
    purchase_date,
    purchase_device,
    spent
FROM CombinedData
WHERE row_num = 1;

-- Get the users who spent more than the average spent by all users:

SELECT a.uid, a.spent, g."group"
FROM activity a
LEFT JOIN groups g ON a.uid = g.uid
WHERE a.spent > (
  SELECT AVG(spent)
  FROM activity
);

-- Calculate the average spending for each day of the week:
SELECT EXTRACT(DOW FROM dt) AS day_of_week, AVG(spent) AS average_spent
FROM activity
GROUP BY EXTRACT(DOW FROM dt)
ORDER BY day_of_week;

-- Get the top 5 countries with the highest total spending:

SELECT u.country, SUM(a.spent) AS total_spent
FROM users u
JOIN activity a ON u.id = a.uid
GROUP BY u.country
ORDER BY total_spent DESC
LIMIT 5;

------

-- Join user information with group data:
SELECT u.id, u.country, u.gender, g.group, g.join_dt, g.device
FROM users u
JOIN groups g ON u.id = g.uid;

-- Calculate total spent per user:
SELECT uid, SUM(spent) AS total_spent
FROM activity
GROUP BY uid;

-- Find the top 10 spenders:
SELECT uid, SUM(spent) AS total_spent
FROM activity
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- Count the number of users in each country:
SELECT country, COUNT(*) AS user_count
FROM users
GROUP BY country;

-- Calculate the average spending per gender:
SELECT u.gender, AVG(a.spent) AS average_spent
FROM users u
JOIN activity a ON u.id = a.uid
GROUP BY u.gender;


