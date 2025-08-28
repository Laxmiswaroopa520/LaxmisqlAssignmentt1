use [312local];
-- 1.scalar functions (returns a single value)
-- types:
--🔹 Types of Scalar Functions (by usage)

--We can categorize them based on what they do:

--String-related scalar functions

--Date and time scalar functions

--Mathematical scalar functions

--Validation/Business rule scalar functions


--1. --String-related scalar functions
create function dbo.fnname1(@fullname varchar(10))
returns varchar(10)
as
begin
    declare @initials varchar(10);
    select @initials=left(@fullname,1);
    return upper(@initials);
end;
go
select dbo.fnname1('swaroopa');


-- I want to set the initials with left(@fullname,5);
-- to alter the function

alter function dbo.fnname1(@fullname varchar(10))
returns varchar(20)
as 
begin
    declare @intials varchar(10);
    select @intials=left(@fullname,5);
    return @intials;
end;
go
select dbo.fnname1('swaroopa');


--2.Date and time scalar functions
create function dbo.calculateage(@dob date)
returns int
as
begin
    declare @age int;
    select @age=datediff(year,@dob,getdate());
    return @age;
end;
go
select dbo.calculateage('2003-07-21');

--3.Mathematical scalar functions
alter function dbo.mathsc(@num int)
returns int
as
begin
    return @num*@num;
end;
go
select dbo.mathsc(30);

-- 4. Business Rule Validation
create function dbo.businessvalid(@dob date)
returns bit
as
begin
    declare @age int;
    declare @isvalid bit
    set @age=datediff(year,@dob,getdate());

    if(month(@dob)>month(getdate()))or (month(@dob)=month(getdate())and (day(@dob)>day(getdate())))
        set @age=@age-1;

    if(@age>=18)
        set @isvalid=1;
    else 
      set  @isvalid=0;
    return @isvalid;
end;
go
select dbo.businessvalid('2003-07-21');
select dbo.businessvalid('2010-07-21');



                -- 2. Inline table valued function  ((Here,no begin,no end))
--(A) Filtering Functions:

--Functions that return filtered rows based on parameters.
use [312local];
--1. Get students of a specific department.
alter function dbo.departfunc(@deid int)
returns table
as
return(
        select name,deptid from stud where deptid=@deid

);
go
select * from dbo.departfunc(101);


--2. (B) Lookup Functions

-- Functions that return a set of related values (like a lookup table).

-- Example: Get all departments with their HODs.
create function dbo.getalldepart()
returns table
as
return (
        select d.deptname,d.hod from depart d 
        );
        go
select * from dbo.getalldepart();

-- 3.(C) Joining Functions
-- Functions that can be joined with other tables (like parameterized subqueries).
--  Students with their department details.
create function dbo.departstud()
returns table
return(
    select s.name,d.deptname,d.deptid from stud s inner join depart d on s.deptid=d.deptid
        
            
              );

    go
    select * from dbo.departstud();

    -- (D) Aggregation Functions  
   
  -- Functions that return summary results.

--  Example: Department-wise student count.

create function dbo.aggre()
returns table
as
return(
    
        select d.deptname,count(s.stdid) as ctt from depart d left join stud s on s.deptid=d.deptid         
        group by d.deptname
            -- alias name beside count(s.stdid) is mandatory
);   
        go
        select * from dbo.aggre();

                -- 3.Multi Statement Table Valued Functions

--it is really necessary to define the structure of the return table in a Multi-Statement Table-Valued Function (MSTVF).

-- Example 1 — Simple MSTVF: Students by specific Department
create function dbo.studb(@deptid int)
returns @resulttable table(
    stdname varchar(10),deptid int
)
as
begin
        insert into @resulttable 
        select s.name,s.deptid from stud s where s.deptid=@deptid;
        return;
end;
go
select * from dbo.studb(101);

-- Example2:Suppose you want students only above age 18 per department.
create function dbo.agecal(@deptid int)
returns @resulttab table(
stuname varchar(10),age int;
)
as
begin
        insert into @resulttab 
        select s.name ,datediff(year,s.dob,getdate()) int from stud s where s.deptid=@deptid and datediff(year,s.dob,getdate())>=18;
        return;
end;
go
select * from dbo.agecal(101);
