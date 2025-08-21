-- Assignment 2:

/*

Guys Check with the Assignment -2
1)Write a query to find the all the names which are similar in pronouncing as suresh, sort the result in the order of similarity
2)write a query to find second highest salary in organisation without using subqueries and top
3)write a query to find max salary and dep name from all the dept with out using top and limit
4)Write a SQL query to maximum number from a table without using MAX or MIN aggregate functions.
Consider the numbers as mentioned below:
7859
6897
9875
8659
7600
7550
5) Write an SQL query to fetch all the Employees who are also managers from the Employee Details table.
*/

select * from empman;
alter table empman add salary int;
update empman set salary=22600 where eid=1;
update empman set salary=34000 where eid=5;
update empman set salary=16700 where eid=2;

update empman set salary=16700 where eid=3;
select * from empman;


-- 1)Write a query to find the all the names which are similar in pronouncing as suresh, sort the result in the order of similarity
-- soundex neglects a,e,i,o,u,h,w and y ignored unless they're the first letter of the string.

/*SELECT SOUNDEX('Suresh'), SOUNDEX('Suresh'), SOUNDEX('Sourisha');
select difference('suresh','ures');
*/
select empname,soundex(empname,'suresh')as code,difference(empname,'suresh')as similaritycheck from empman 
where difference (empname,'suresh')>0 order by similaritycheck desc;


-- 2)write a query to find second highest salary in organisation without using subqueries and top

				-- 1.using dense_rank
with highestsal as(
select salary,empname,dense_rank()over(order by salary desc)as rankk from empman)
select salary,empname from highestsal where rankk=2;

				-- 2.using row number (note: you cant use distinct with order by
with highestsal as(
select distinct salary from empman
),
ranked as(
select salary,row_number() over(order by  salary desc)as rankk from highestsal)
select salary from ranked where rankk=2;

-- 3)write a query to find max salary and dep name from all the dept with out using top and limit
						-- way 1: using dense rank
select * from empman;
update empman set salary=34000 where eid=4;
update  empman set deptname='cse' where eid=1 or eid=3;
update  empman set deptname='ece' where eid=2 or eid=4 or eid=5;
alter table empman add deptname varchar(10);


with maxsal as(
select salary,deptname,dense_rank()over(partition by deptname order by salary desc)as maxsalperdept from empman)
select salary,deptname  from maxsal where maxsalperdept=1;

					-- or  way 2: using row_number
 with maxrow as(					-- here 1st calculate distinct salary along with its department name 
 select distinct salary,deptname from empman),
 ranked as (
 select salary,deptname,row_number() over(partition by deptname order by salary desc)as maxsal from maxrow)
 select salary,deptname from ranked where maxsal=1;


-- 4)Write a SQL query to maximum number from a table without using MAX or MIN aggregate functions.
		-- a.here i considered salary column as a number column
select top 1 salary from empman order by salary desc ;

		-- b.using row_number
with bignum as(
select salary,row_number()over(order by salary desc) as rankk from empman)
select salary from bignum where rankk=1 ;

		--c.using dense rank
with bignum as(
select distinct salary from empman
),
ranked as(
select salary,dense_rank() over(order by salary desc)as rankk from bignum)
select salary from ranked where rankk=1;

-- 5) Write an SQL query to fetch all the Employees who are also managers from the Employee Details table.
select * from empman;
				-- 1st way using in operator
 select * from empman where eid in(select managerid from empman);


			 -- 2nd way using intersect
 select * from empman where eid=(
 select eid 
 intersect
SELECT ManagerID
FROM Empman);


			-- 3rd way using joins
SELECT distinct e.*
FROM Empman e
JOIN Empman m ON e.Eid = m.ManagerID;
