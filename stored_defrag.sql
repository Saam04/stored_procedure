select * from [Person].[Person]

select i.name as indexname, i.type_desc
from sys.indexes i
where object_id = OBJECT_ID('Person.Person_test')

create nonclustered index ix_person_lastname
on person.person (lastname)

exec sp_helpindex'person.person'

select * from [Person].[Person_Test]

create nonclustered index IX_Person_LastName1
ON [Person].[Person_Test] (lastname)


use AdventureWorks2012
go 

create or alter procedure dbo.reorg9_lastname

as
begin
    set nocount on

    declare @fragpercent float
    declare @pagecount int
    declare @indexname sysname = 'ix_person_lastname1' --implicitly not null
    declare @sql nvarchar(max)

    select 
        @fragpercent = avg_fragmentation_in_percent, -- denotes the avg % of the fragmentation
        @pagecount = page_count
    from sys.dm_db_index_physical_stats (
        db_id(), object_id('person.person_test'), 
        indexproperty(object_id('person.person_test'), @indexname, 'indexid'),
        null, 'limited'
    )

    if @fragpercent > 5 and @pagecount > 50
    begin
        set @sql = 'alter index [' + @indexname + '] on person.person_test reorganize;'
        print 'reorganizing data: ' + @sql
        exec sp_executesql @sql
    end
    else
    begin
        print 'index fragmentation is low. No action taken.';
    end
end
go

exec dbo.reorg9_lastname





select i.name as index_name
from sys.indexes i
where object_id = object_id('person.person_Test');





PRINT 'Index ID: ' + CAST(@index_id AS VARCHAR);





-- Create a copy of Person.Person for testing
SELECT *
INTO Person.Person_Test
FROM Person.Person;

-- Create an index on LastName (same as your procedure uses)

-- Insert 500 rows with random LastNames
INSERT INTO Person.Person_Test (BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, AdditionalContactInfo, Demographics, rowguid, ModifiedDate)
SELECT TOP 500 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 20000, -- avoid PK collision
    'EM', 0, NULL,
    LEFT(NEWID(), 5), NULL,
    LEFT(NEWID(), 8), NULL,
    0, NULL, NULL,
    NEWID(), GETDATE()
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;

-- Delete 200 random rows to create gaps and fragment pages
DELETE FROM Person.Person_Test
WHERE BusinessEntityID % 5 = 0;

ALTER INDEX [ix_person_lastname1] 
ON Person.Person_Test REORGANIZE;

select SERVERPROPERTY('engine') as engine,
       serverproperty('productversion') as version,
       SERVERPROPERTY('engineedition') as engineedition