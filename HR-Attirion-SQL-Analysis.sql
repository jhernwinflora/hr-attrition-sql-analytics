-- hr attrition 
-- Database Setup & Schema
create table hr_attrition
	(
		Age int,
		Attrition varchar (10),
		BusinessTravel varchar(30),
		DailyRate int,
		Department varchar(30),
		DistanceFromHome int,
		Education int,
		EducationField varchar(30),
		EmployeeCount int,
		EmployeeNumber int primary key
	)

select * from hr_attrition


-- (Overall Attrition Rate)
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS total_attrition,
    ROUND(
        (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS attrition_rate_percentage
FROM hr_attrition;	


-- Departmental Breakdown
SELECT 
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(
        (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS attrition_rate
FROM hr_attrition
GROUP BY Department
ORDER BY attrition_rate DESC;

-- The Commute Impact (Distance From Home)
SELECT 
    CASE 
        WHEN DistanceFromHome <= 5 THEN 'Near (0-5 miles)'
        WHEN DistanceFromHome <= 15 THEN 'Moderate (6-15 miles)'
        ELSE 'Far (16+ miles)'
    END AS commute_distance,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(
        (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS attrition_rate
FROM hr_attrition
GROUP BY 
    CASE 
        WHEN DistanceFromHome <= 5 THEN 'Near (0-5 miles)'
        WHEN DistanceFromHome <= 15 THEN 'Moderate (6-15 miles)'
        ELSE 'Far (16+ miles)'
    END
ORDER BY attrition_rate DESC;

--Age Demographics & Turn-over
SELECT 
    CONCAT(FLOOR(Age / 10) * 10, '-', (FLOOR(Age / 10) * 10) + 9) AS age_group,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(
        (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS attrition_rate
FROM hr_attrition
GROUP BY FLOOR(Age / 10)
ORDER BY age_group;


--Business Travel vs. Attrition
SELECT 
    BusinessTravel,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(
        (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS attrition_rate
FROM hr_attrition
GROUP BY BusinessTravel
ORDER BY attrition_rate DESC;

--Advanced Portfolio Insights (Window Functions)
WITH DeptEducationAttrition AS (
    SELECT 
        Department,
        EducationField,
        COUNT(*) AS total_staff,
        ROUND(
            (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
            2
        ) AS attrition_rate
    FROM hr_attrition
    GROUP BY Department, EducationField
)
SELECT 
    Department,
    EducationField,
    total_staff,
    attrition_rate,
    RANK() OVER (PARTITION BY Department ORDER BY attrition_rate DESC) AS risk_rank
FROM DeptEducationAttrition
WHERE total_staff > 5; -- Filters out statistically insignificant sample sizes