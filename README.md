# hr-attrition-sql-analytics
An end-to-end SQL project analyzing employee demographics, travel frequency, and distance from home to uncover key drivers of HR attrition.

# HR Attrition Analytics: Uncovering Turnover Drivers with SQL

## 📌 Project Overview
Employee turnover is an expensive problem for any organization. This project utilizes SQL to deep-dive into the famous **IBM HR Analytics Employee Attrition & Performance** dataset. 

The goal is to extract actionable intelligence regarding why employees leave, focusing on demographics, department structures, commute stress, and business travel habits.

---

## 📊 Dataset Features Evaluated
The dataset tracks several key employee metrics, including:
* **Demographics:** Age, Education, EducationField
* **Operational:** Department, EmployeeNumber, EmployeeCount
* **Work-Life Balance:** DistanceFromHome, BusinessTravel, DailyRate
* **Target Metric:** Attrition (Yes/No)

---

## 🛠️ Tech Stack & SQL Concepts Used
* **Dialect:** PostgreSQL 
* **Aggregations & Filters:** `SUM(CASE WHEN...)`, `ROUND()`, `GROUP BY`
* **Common Table Expressions (CTEs):** For multi-layered logical analysis
* **Window Functions:** `RANK() OVER (PARTITION BY...)` to identify localized risks

---

## 🔍 Key Questions Answered & SQL Scripts
```sql
1. Database Setup & Schema
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
    
2. What percentage of the workforce has left?
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS total_attrition,
    ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS attrition_rate_percentage
FROM hr_attrition;

3. Are people leaving the company as a whole, or is there a toxic culture/burnout in a specific department?
SELECT 
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY Department
ORDER BY attrition_rate DESC;

4. Does a long commute drive people to quit? Let's bucket the distances to find out.
SELECT 
    CASE 
        WHEN DistanceFromHome <= 5 THEN 'Near (0-5 miles)'
        WHEN DistanceFromHome <= 15 THEN 'Moderate (6-15 miles)'
        ELSE 'Far (16+ miles)'
    END AS commute_distance,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY 1
ORDER BY attrition_rate DESC;

5. Are we losing young talent or seasoned veterans?
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

6. Does frequent travel correlate with higher attrition?
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

-- Which specific education backgrounds face the highest risk within each department? (Advanced Risk-Ranking)
WITH DeptEducationAttrition AS (
    SELECT 
        Department,
        EducationField,
        COUNT(*) AS total_staff,
        ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS attrition_rate
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
WHERE total_staff > 5;
```

## Key Insights & Recommendations
1. Address Commute Burnout: Employees living 16+ miles away exhibit a significantly higher attrition rate. Recommendation: Introduce hybrid/remote options for high-distance roles.
2. Sales Department Focus: The Sales department holds the highest turnover rate structurally. Recommendation: Review commission structures and sales target distributions.
3. Targeted Retaining Policies: The highest risk ranks belong to early-career fields. Recommendation: Implement clearer mentorship structures for junior employees in high-turnover educational tracks.



