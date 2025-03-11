-- Basic Questions

-- Write a query to retrieve all employee names (first and last) along with their job titles.
select FirstName, LastName, JobTitle
from employeedemographics join employeesalary
on employeedemographics.EmployeeID=employeesalary.EmployeeID;

-- Find all employees who are older than 30.
select *
from employeedemographics
where age>30;

-- Get the count of male and female employees.
select gender, count(gender) as Number
from employeedemographics
group by gender;

-- Retrieve the highest salary from the EmployeeSalary table.
select max(salary) as Highest_Salary
from employeesalary;

-- Find employees whose first names start with the letter 'A'.
select *
from employeedemographics
where FirstName like "A%";

-- Intermediate Questions

-- Use a CASE statement to categorize employees' salaries as ‘Low’ (<50,000), ‘Medium’ (50,000 - 100,000), or ‘High’ (>100,000).
SELECT EmployeeID, Salary,
    CASE 
        WHEN Salary < 50000 THEN 'Low'
        WHEN Salary BETWEEN 50000 AND 100000 THEN 'Medium'
        ELSE 'High'
    END AS Salary
FROM EmployeeSalary;

-- Write a subquery to find employees who earn more than the average salary.
select * 
from employeedemographics join employeesalary
on employeedemographics.EmployeeID=employeesalary.EmployeeID
where salary>(select avg(salary) from employeesalary);

-- Create a Common Table Expression (CTE) that lists employees with salaries above 50,000.
WITH HighSalaryEmployees AS (
    SELECT EmployeeID, Salary 
    FROM EmployeeSalary 
    WHERE Salary > 50000
)
SELECT * FROM HighSalaryEmployees;

-- Write a query using window functions to rank employees based on their salary in descending order.
-- select * 
-- from employeesalary
-- order by salary desc;

SELECT EmployeeID, Salary, 
    RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM EmployeeSalary;

-- Create a temporary table that stores employees who are younger than 30 and have a salary greater than 60,000.
Create temporary table YoungHighEarnerd as
select employeedemographics.FirstName, employeesalary.salary
from employeedemographics join employeesalary
on employeedemographics.EmployeeID=employeesalary.EmployeeID
where age<30 and Salary>60000;

-- Advanced Questions

-- Write a stored procedure that takes an employee's first name as input and returns their job title and salary.
DELIMITER //
CREATE PROCEDURE GetEmployeeDetails(IN empFirstName VARCHAR(50))
BEGIN
    SELECT e.FirstName, e.LastName, s.JobTitle, s.Salary 
    FROM EmployeeDemographics e
    JOIN EmployeeSalary s ON e.EmployeeID = s.EmployeeID
    WHERE e.FirstName = empFirstName;
END //
DELIMITER ;

CALL GetEmployeeDetails('Jim');

-- Create a trigger that logs an entry into a new table whenever a new employee is inserted into EmployeeDemographics.
CREATE TABLE EmployeeLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    ActionTaken VARCHAR(50),
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
CREATE TRIGGER LogEmployeeInsert
AFTER INSERT ON EmployeeDemographics
FOR EACH ROW
BEGIN
    INSERT INTO EmployeeLog (EmployeeID, ActionTaken)
    VALUES (NEW.EmployeeID, 'Inserted New Employee');
END;
//
DELIMITER ;

-- Write an event that automatically updates salaries by 5% every January 1st.
DELIMITER //
CREATE EVENT AnnualSalaryIncrease
ON SCHEDULE EVERY 1 YEAR
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 YEAR)
DO
BEGIN
    UPDATE EmployeeSalary 
    SET Salary = Salary * 1.05;
END;
//
DELIMITER ;

-- Use a string function to extract and display only the last three characters of employees' first names.
select FirstName, right(FirstName,3) as Last3chars
from employeedemographics;

-- Use a subquery and a window function to find the top 3 highest-paid employees.
SELECT EmployeeID, Salary 
FROM (
    SELECT EmployeeID, Salary, 
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM EmployeeSalary
) ranked
WHERE SalaryRank <= 3;