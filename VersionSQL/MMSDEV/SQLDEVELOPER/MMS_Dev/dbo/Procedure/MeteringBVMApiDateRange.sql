/****** Object:  Procedure [dbo].[MeteringBVMApiDateRange]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 21 Jun 2022
--Comments : Call Metering API For date range using SQLJobMonitor
--======================================================================
--  [dbo].[MeteringBVMApiDateRange] '2022-6-6' , '2022-6-10'
CREATE PROCEDURE [dbo].[MeteringBVMApiDateRange]
@pStartDate date =null,
@pEndDate date =null

AS
BEGIN
DECLARE @INC_Day as int=1;
DROP TABLE If EXISTS #TempRows

;with ROWCTE as  
   (  
      SELECT @pStartDate as dateValue   
		UNION ALL  
      SELECT DATEADD(Day, @INC_Day, dateValue) 
  FROM  ROWCTE  
  WHERE dateValue < @pEndDate
    )  
	SELECT * 
INTO #TempRows
FROM ROWCTE
OPTION(MAXRECURSION 0) --There is no way to perform a recursion more than 32767 
select dateValue from #TempRows

DECLARE @vCurrentDate date=null;
DECLARE @pType as int=10;
DECLARE date_cursor CURSOR FOR
SELECT dateValue
FROM #TempRows
order by 1;

OPEN date_cursor

FETCH NEXT FROM date_cursor
INTO @vCurrentDate

WHILE @@FETCH_STATUS = 0
BEGIN
   DECLARE @StartDateTime varchar(50)  
   Declare @b as varchar(50)  

	Print 'current date  '+ cast(@vCurrentDate as varchar(max))
	      set @b= (select FORMAT ( @vCurrentDate, 'dd-MM-yyyy') as date);  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
  print @StartDateTime  
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime,@pType=@pType;  

FETCH NEXT FROM date_cursor
INTO @vCurrentDate

END
CLOSE date_cursor;
DEALLOCATE date_cursor;





 END
