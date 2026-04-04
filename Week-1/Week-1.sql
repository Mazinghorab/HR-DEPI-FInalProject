--  Weeks 1

-- #1 Making Tables

CREATE TABLE Employee (
    EmployeeID              INT PRIMARY KEY,
    FirstName               VARCHAR(100),
    LastName                VARCHAR(100),
    Age                     INT,
    Gender                  VARCHAR(20),
    Department              VARCHAR(100),
    JobRole                 VARCHAR(100),
    Salary                  DECIMAL(12,2),
    HireDate                DATE,
    Attrition               VARCHAR(5),       -- 'Yes' / 'No'
    Education               INT,              -- FK → EducationLevel
    EducationField          VARCHAR(100),
    MaritalStatus           VARCHAR(50),
    OverTime                VARCHAR(5),
    BusinessTravel          VARCHAR(100),
    DistanceFromHome_KM     INT,
    StockOptionLevel        INT,
    YearsAtCompany          INT,
    YearsInMostRecentRole   INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager    INT,
    State                   VARCHAR(100),
    Ethnicity               VARCHAR(100)
);

CREATE TABLE PerformanceRating (
    PerformanceID               INT PRIMARY KEY,
    EmployeeID                  INT REFERENCES Employee(EmployeeID),
    ReviewDate                  DATE,
    JobSatisfaction             INT,
    WorkLifeBalance             INT,
    SelfRating                  INT,
    ManagerRating               INT,
    EnvironmentSatisfaction     INT,
    RelationshipSatisfaction    INT,
    TrainingOpportunitiesTaken  INT
);

CREATE TABLE EducationLevel (
    EducationLevelID  INT PRIMARY KEY,
    EducationLevel    VARCHAR(100)
);

CREATE TABLE RatingLevel (
    RatingID     INT PRIMARY KEY,
    RatingLevel  VARCHAR(50)
);

CREATE TABLE SatisfiedLevel (
    SatisfactionID    INT PRIMARY KEY,
    SatisfactionLevel VARCHAR(50)
);


-- #2 Detecting any Duplication or Null Values  

SELECT COUNT(*) - COUNT(DISTINCT EmployeeID) AS duplicate_employees
FROM Employee;

SELECT COUNT(*) - COUNT(DISTINCT PerformanceID) AS duplicate_perf_rows
FROM PerformanceRating;

SELECT
    SUM(CASE WHEN FirstName             IS NULL THEN 1 ELSE 0 END) AS null_FirstName,
    SUM(CASE WHEN Salary                IS NULL THEN 1 ELSE 0 END) AS null_Salary,
    SUM(CASE WHEN Department            IS NULL THEN 1 ELSE 0 END) AS null_Department,
    SUM(CASE WHEN HireDate              IS NULL THEN 1 ELSE 0 END) AS null_HireDate,
    SUM(CASE WHEN Attrition             IS NULL THEN 1 ELSE 0 END) AS null_Attrition
FROM Employee;


-- #3 Making Master View

CREATE OR REPLACE VIEW vw_Master AS
SELECT
    e.*,
    CASE
        WHEN e.Salary <= 50000               THEN 'Low'
        WHEN e.Salary <= 80000               THEN 'Medium'
        WHEN e.Salary <= 110000              THEN 'High'
        ELSE                                      'Very High'
    END AS SalaryBand,

    -- Making Attriation to '1/0'
    CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END AS AttritionBinary,

    -- Lookup Tables
    el.EducationLevel,
    sr.RatingLevel  AS SelfRatingLabel,
    mr.RatingLevel  AS ManagerRatingLabel,
    sl.SatisfactionLevel AS JobSatLabel,
    lp.ReviewDate,
    lp.JobSatisfaction,
    lp.WorkLifeBalance,
    lp.SelfRating,
    lp.ManagerRating,
    lp.EnvironmentSatisfaction,
    lp.RelationshipSatisfaction,
    lp.TrainingOpportunitiesTaken
FROM Employee e
LEFT JOIN EducationLevel el
       ON e.Education = el.EducationLevelID
LEFT JOIN RatingLevel sr
       ON lp.SelfRating = sr.RatingID
LEFT JOIN RatingLevel mr
       ON lp.ManagerRating = mr.RatingID
LEFT JOIN SatisfiedLevel sl
       ON lp.JobSatisfaction = sl.SatisfactionID
-- Subqueries "Making sure of all Emplyees Performance"
LEFT JOIN (
    SELECT *
    FROM PerformanceRating pr1
    WHERE ReviewDate = (
        SELECT MAX(pr2.ReviewDate)
        FROM PerformanceRating pr2
        WHERE pr2.EmployeeID = pr1.EmployeeID
    )
) lp ON e.EmployeeID = lp.EmployeeID;