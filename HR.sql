
/*This SQL is used to determine findings on employee database*/

/*Creating a table named 'hr' with the following columns shown below.*/

create table hr
			(Employee_Name varchar,
			  EmpID int,
			  MarriedID bool,
			  MaritalStatusID int,
			  GenderID int, 
			  EmpStatusID int,
			  DeptID int,
			  PerfScoreID int,
			  FromDiversityJobFairID int,
			  Salary int, 
			  Termd int,
			  PositionID int,
			  Position varchar,
			  State char(2),
			  Zip int,
			  DOB date,
			  Sex char(1),
			  MaritalDesc varchar,	
			  CitizenDesc varchar,
			  HispanicLatino bool,
			  RaceDesc	varchar, 
			  DateofHire date, 
			  DateofTermination date,
			  TermReason varchar, 	
			  EmploymentStatus varchar,
			  Department varchar,
			  ManagerName varchar,
			  ManagerID int,
			  RecruitmentSource varchar,
			  PerformanceScore varchar,
			  EngagementSurvey double precision,
			  EmpSatisfaction int,
			  SpecialProjectsCount int,
			  LastPerformanceReview_Date date,
			  DaysLateLast30 int,
			  Absences int
			 )
			 
copy hr from 'F:\Power BI\Data5-HR\HRDataset_v14.csv'  delimiter ',' csv header

/*The table was altered by changing the column type from integer to boolean*/
alter table hr
alter column GenderID type  boolean USING GenderID::boolean

/*To check if everything is in order: */
select * from hr

/*Is there any relationship between who a person works for and their performance score? */

select  
	Employee_Name,
	ManagerName,
	avg(PerfScoreID) over(partition by ManagerName) as average
from hr
order by average

/*What is the overall diversity profile of the organization?*/

-- if gender ID boolean value is 'TRUE' the employee is a 'Male'
select racedesc, 
	count(racedesc) as race_count,
	count(case when genderid = true then 1 end) as true_count
from hr
group by racedesc

/*What are our best recruiting sources if we want to ensure a diverse organization? */
--top 3 racesdec are 'White' , 'Black or African American', and 'Asian' 
select 
	recruitmentsource,
	count(recruitmentsource),
	sum(case when racedesc = 'White' then 1 else 0 end) as white_count,
	sum(case when racedesc = 'Asian' then 1 else 0 end) as asian_count,
	sum(case when racedesc = 'Black or African American' then 1 else 0 end) as black_count
	
from hr
where racedesc IN('White', 'Asian', 'Black or African American')
group by recruitmentsource

/*Can we predict who is going to terminate and who isn't? What level of accuracy can we achieve on this?*/
-- I checked the 'Active' employees on the number of absentees. The number varries from 1 to 20 but more frequently on the 15-20.

select *
from hr
where employmentstatus = 'Active'
order by absences desc

/* I checked the 'Inactive' employees for the trends in absentees. It turns out that an employee is most likely to be terminated when the number of 
 absents are high*/
 
select
	empid,
	marriedid,
	engagementsurvey, 
	empsatisfaction,
	performancescore,
	employmentstatus,
	termreason,
	absences
from hr
where employmentstatus != 'Active' 
order by absences desc

/*
Top 3 reasons are:
1. Another position
2. Unhappy
3. More money
  Which is based on the syntax below
*/

select 
	termreason,
	count(termreason) as reason_count
from hr
where employmentstatus != 'Active'
group by termreason
order by reason_count desc

/* I found out that 90% of the employees terminated are from the production technician*/
select 
	position,
	count(position) as count
from hr
where employmentstatus !='Active'
group by position
order by count desc

/*Are there areas of the company where pay is not equitable?*/
-- answer: yes, there is

select
	position,
	salary,
	age(dateoftermination, dateofhire) as yrs_of_serv
from hr
order by position

