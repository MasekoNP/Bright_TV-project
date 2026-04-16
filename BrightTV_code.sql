--------------------------------------------------------------------------------
-- 1. I want to see the bright TV, with viewer profiles and viewership tables 
--For data profiles
SELECT *
FROM bright_learn.default.bright_tv_dataset
LIMIT 50;

-- For vieweship data
SELECT * 
FROM bright_learn.default.bright_tv_dataset_2
LIMIT 50; 

-- The tables could be useful when joined together
-- I used the RIGHT JOIN to join viewership table to viewer profiles
-- I then downloaded results from the join, put them in a Excel spreadsheet and uploaaded the spreadsheet
SELECT A.UserID, A.Name_, A.Surname, A.Email, A.Gender, A.Race, A.Age, A.Province, A.Social_Media_Handle, B.Channel2, B.RecordDate2, B.Duration2
FROM bright_learn.default.bright_tv_dataset AS A
RIGHT JOIN bright_learn.default.bright_tv_dataset_2 AS B
ON A.UserID = B.UserID;

-- I want to see the joined table, with viewer profiles and viewership tables
SELECT *
FROM bright_learn.default.bright_tv
LIMIT 100;

-- 2. Checking for duplicates for the UserID
-- There are duplicates UserID
SELECT UserID,
      COUNT(*) AS number_of_rows
FROM bright_learn.default.bright_tv
GROUP BY UserID
HAVING COUNT(*) > 1;

-- 3. Checking for NULL values in all columns
-- There are no NULL values returned
SELECT *
FROM bright_learn.default.bright_tv
WHERE
    UserID IS NULL 
    OR Name_ IS NULL 
    OR Surname IS NULL 
    OR Email IS NULL 
    OR Gender IS NULL 
    OR Race IS NULL 
    OR Age IS NULL 
    OR Province IS NULL 
    OR Social_Media_Handle IS NULL
    OR Channel2 IS NULL
    OR RecordDate2 IS NULL
    OR Duration2 IS NULL; 

-- 4. Missing values
-- 1007 count of missing names
SELECT COUNT(*) AS missing_names 
FROM bright_learn.default.bright_tv
WHERE  
      Name_ IN(' ','None');

-- 1007 count of missing surnames
SELECT COUNT(*) AS missing_surnames 
FROM bright_learn.default.bright_tv
WHERE  Surname IN(' ', 'None');
 

-- 0 counts of missing emails
SELECT COUNT(*) AS missing_emails 
FROM bright_learn.default.bright_tv
WHERE Email IN(' ','None');

-- 789 count of missing gender
SELECT COUNT(*) AS missing_gender 
FROM bright_learn.default.bright_tv
WHERE Gender IN(' ','None');

-- 1595 count of missing races
SELECT COUNT(*) AS missing_race 
FROM bright_learn.default.bright_tv
WHERE Race IN(' ','None');

-- 789 count of missing provinces
SELECT COUNT(*) AS missing_province 
FROM bright_learn.default.bright_tv
WHERE Province IN(' ','None');

-- 1007 count of social media handles
SELECT COUNT(*) AS missing_social_media_handle 
FROM bright_learn.default.bright_tv
WHERE Social_Media_Handle IN(' ','None'); 

-- 0 count of missing channel2
SELECT COUNT(*) AS missing_Channel2 
FROM bright_learn.default.bright_tv
WHERE Channel2 IN(' ','None'); 

-- 0 count of missing RecordDate2
SELECT COUNT(*) AS missing_recorddate2 
FROM bright_learn.default.bright_tv
WHERE RecordDate2 IN(' ','None');

-- 0 count of Duration2
SELECT COUNT(*) AS missing_duration2 
FROM bright_learn.default.bright_tv
WHERE Duration2 IN(' ','None'); 

--------------------------------------------------------------------------------
-- With gender, there is male, female, None and blankspace
SELECT DISTINCT Gender
FROM bright_learn.default.bright_tv;

-- Also, with gender, there is a count of 1005 perople with 0 as their age
SELECT COUNT(*) AS missing_Age
FROM bright_learn.default.bright_tv
WHERE Age = 0;

-- Update 0 in Age to NULL
UPDATE bright_learn.default.bright_tv
SET Age = NULL
WHERE Age = 0;

-- With race, there is coloured, black, white, None, indian_asian, other and blankspace
SELECT DISTINCT Race
FROM bright_learn.default.bright_tv;

-- Checking the age range
-- There is a minimum range of 0 to 114
SELECT MIN(Age) AS Minimum_age,
       MAX(Age) AS Highest_age
FROM bright_learn.default.bright_tv;

-- With province Free State, Gauteng, Mpumalanga, Western Cape, Kwazulu Natal, Northern Cape, None, Eastern Cape, Limpopo, North West, and blankspace
SELECT DISTINCT Province
FROM bright_learn.default.bright_tv;
------------------------------------------------------------------
--Aggragating everything
SELECT 
      UserID,  
      Name_,
      Surname, 
      Email, 
      Gender,  
      Race,  
      Age,
           CASE 
                WHEN Age < 12 THEN 'Child'
                WHEN Age BETWEEN 13 AND 19 THEN 'Teenage'
                WHEN Age BETWEEN 20 AND 35 THEN 'Youth'
                WHEN Age BETWEEN 36 AND 59 THEN 'Middle age adult'
                ELSE 'Elderly'
            END AS age_groups,  
      Province, 
      Social_Media_Handle,
      Channel2, 
      RecordDate2,
      
      -- Changing the record time format from UTC to SAST
      TRY_CAST(NULLIF(RecordDate2, 'null') AS TIMESTAMP) + INTERVAL 2 HOURS AS SA_rcord_Time,
      CAST(SA_rcord_Time AS DATE) AS record_date,
      Dayname(SA_rcord_Time) AS Day_name,
        CASE 
            WHEN Dayname(SA_rcord_Time) IN ('Sat', 'Sun') THEN 'Weekend'
            ELSE 'Weekday'
      END AS record_date,
      Monthname(SA_rcord_Time) AS Month_name_for_rec,
      Dayofmonth(SA_rcord_Time) AS day_of_month_for_rec,
      
      -- Adding time claassification  
        CASE 
                WHEN date_format(SA_rcord_Time, 'HH:MM:SS') BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
                WHEN date_format(SA_rcord_Time, 'HH:MM:SS') BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
                WHEN date_format(SA_rcord_Time, 'HH:MM:SS') BETWEEN '17:00:00' AND '23:59:59' THEN 'Evening'
        END AS time_formats_for_rec,
      
      Duration2,
      -- Changing the duration time format from UTC to SAST
      TRY_CAST(NULLIF(Duration2, 'null') AS TIMESTAMP) + INTERVAL 2 HOURS AS SA_duration_Time,
      (hour(SA_duration_Time) * 60) + minute(SA_duration_Time)+ (second(SA_duration_Time) / 60) AS duration_minutes,
      CAST(SA_duration_Time AS DATE) AS duration_date,
      Dayname(SA_duration_Time) AS Day_name2,
        CASE 
            WHEN Dayname(SA_duration_Time) IN ('Sat', 'Sun') THEN 'Weekend'
            ELSE 'Weekday'
        END AS dur_dates,
      Monthname(SA_duration_Time) AS Month_name_for_dur,
      Dayofmonth(SA_duration_Time) AS day_of_month_for_dur
      
FROM bright_learn.default.bright_tv;
