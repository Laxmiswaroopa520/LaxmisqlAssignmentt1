-- 1. Write a script to extracts all the numerics from Alphanumeric String.

-- 1st way
declare @str varchar(50)='A&789AHEW37';
declare @i int=1;
declare @ch varchar;
declare @result varchar(50)='';
while @i<=len(@str)
begin
    set @ch=substring(@str,@i,1);
     if @ch like '[0-9]'

         set @result=@result+@ch;
     
    set @i=@i+1;
 end;
    
    select @result ;


    -- 2nd way

 declare @str varchar(50)='A&789AHEW37';
declare @i int=1;
declare @ch char(1);
declare @result varchar(50)='';
declare @temp int;
while @i<=len(@str)
begin
    set @ch=substring(@str,@i,1);
    set @temp=try_cast(@ch as int);

     if @temp in(0,1,2,3,4,5,6,7,8,9)

         set @result=concat(@result,@temp);
      --  set @result=@result+@temp;
     
    set @i=@i+1;
 end;
    
    select @result ;


    -- 3rd way using cursor

    declare @str varchar(50)='SEW576575765SRERERE76567';
    declare @ch char(1);
    declare @result varchar(50)='';
    declare @i int=1;

    declare @tabvar table(ch char(1));       --declare a table variable to store one character in a row
    while @i<=len(@str)
     begin
        insert into @tabvar values(substring(@str,@i,1));
        set @i=@i+1;
     end;


     declare cur cursor for               --declaring a cursor to iterate
            select ch from @tabvar;
    open cur;
    fetch next from cur into @ch;
    while @@FETCH_STATUS=0      -- 0 = success (a row was fetched),-1 = no more rows,-2 = the row is missing.

    begin
        if @ch like '[0-9]'
           -- set @result=concat(@result,@ch)
           set @result =@result+@ch;

        fetch next from cur into @ch;
    end;    
close cur;
deallocate cur;    -- close release the result set where as deallocates frees the cursor defintion

SELECT @result AS NumbersOnly;




-- 2. Write a script to calculate age based on the Input DOB.

create table ques3( id int,name varchar,dob date);
ALTER TABLE Employees
alter table ques3 alter column name varchar(21);
insert into ques3 values(2,'anu','2005-06-02'),(3,'chandhini','2004-09-06');

-- way 1 calculating age for all values 
select datediff(year,dob,getdate())-
case when ((month(dob)>month(getdate())) or (month(dob)=month(getdate()) and  day(dob)>day(getdate())))
then 1 else 0
end as age from ques3;



 -- 3rd alternative simple conversion      (WRONG)
 select datediff(year,dob,getdate())-                                   -- it wont work properly because here,
                                                                         --it takes the date as yyyy-mm-date so which means all the time getdate>dob year so it is false and it never decrements by 1
 case when dob>getdate() then 1 else 0 end as age from ques3;

 -- 4th alternative simple conversion                   (here, style 110 means the format is MM-DD-YYYY so meanwhile first it starts checking from month then year etc..
 select datediff(year,dob,getdate())-
 case when convert(varchar(10),dob,110)>convert(varchar(10),getdate(),110)then 1 else 0 end as age from ques3;





--     print the age of a person 
declare @dob date='2003-07-21';
select 
    @dob,datediff(year,@dob,getdate())              -- subtracting year when the birthday didn't occured yet.
   - case
   when ((month(@dob)>month(getdate()))  or (month(@dob)=month(getdate())) and day(@dob)>day(getdate()))
   then 1 else 0

   end AS age;





-- 3. Create a column in a table and that should 
-- throw an error when we do SELECT * or SELECT of that column. If we select other columns then we should see results



-- way 1  :creating a computed columns.


create table ques2(id int,name varchar(10),errorcol as cast('A' as int) );
insert into ques2 values(1,'swaru'),(2,'chinnu');
select * from ques2;            -- error : Conversion failed when converting the varchar value 'A' to data type int.
select id,name from ques2;      -- works properly
select errorcol from ques2;     -- error: Conversion failed when converting the varchar value 'A' to data type int.

-- way2 : creating a view


create table ques22(id int,name varchar(10));
insert into ques22 values(1,'swaru'),(2,'anusha');
create view errorview as 
    select id,name, cast('abc' as int) as col from ques22;

select * from ques22;  --works
select id,name from ques22;     --works
select id,name from errorview;      --works
select name,col from errorview;     --raises an error..




/*   
4. Display Calendar Table based on the input year. If I give the year 2017 then populate data for 2017 only

Date e.g.  1/1/2017 

DayofYear 1 – 365/366 (Note 1)

Week 1-52/53

DayofWeek 1-7

Month 1-12

DayofMonth 1-30/31 (Note 2)

Note 1: DayofYear varies depending on the number of days in the given year.

Note 2: DayofMonth varies depending on number of days in the given month

Weekly calculations are always for a 7 day period Sunday to Saturday.

*/


create table calendar(name varchar(15),dob date);
insert into calendar values('swaru','2003-07-21'),('chinna','2005-06-2'),('anu','2004-01-31');
insert into calendar values('pranu','2025-12-31');


select datepart(dayofyear,dob) from calendar as dayoftheyear;

select datepart(week,dob) as whichweek from calendar ;
select datepart(weekday,dob) as dayofwe from calendar ;
select datepart(month,dob) as whichmonth from calendar ;
select datepart(day,dob) as dayofmont from  calendar;





/* 5.Display Emp and Manager Hierarchies based on the input till the topmost hierarchy. (Input would be empid)

Output: Empid, empname, managername, heirarchylevel.
*/



create table empman(eid int primary key,empname varchar(20),managerid int );
insert into empman values(2,'anu',1),(3,'pranu',2),(4,'abhinaya',2),(5,'chandhini',3);


DECLARE @InputID INT = 5;

WITH Hierarchy AS
(
    -- Anchor member: start with the input employee
    SELECT 
        Eid,
        EmpName,
        ManagerID,
        CAST(EmpName AS varchar(20)) AS HierarchyPath,
        1 AS HierarchyLevel
    FROM Empman
    WHERE Eid = @InputID

    UNION ALL

    -- Recursive member: getting the manager of the current employee
    SELECT 
        e.Eid,
        e.EmpName,
        e.ManagerID,
        CAST(e.EmpName AS varchar(20)) AS HierarchyPath,
        h.HierarchyLevel + 1
    FROM Empman e
    INNER JOIN Hierarchy h
        ON e.Eid = h.ManagerID
)
SELECT 
    h.Eid,
    h.EmpName,
    m.EmpName AS ManagerName,
    h.HierarchyLevel
FROM Hierarchy h
LEFT JOIN Empman m
    ON h.ManagerID = m.Eid
ORDER BY h.HierarchyLevel;
