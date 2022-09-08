/****** Object:  Procedure [dbo].[ScheduleImportBVMDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

  
  
--======================================================================  
--Author  : Sadaf Malik  
--Reviewer : <>  
--CreatedDate : 11 March 2022  
--Comments : Import BVM Data From API  
--======================================================================  
--  [dbo].[ScheduleImportBVMDataFromAPI] @pType=4  
CREATE PROCEDURE [dbo].[ScheduleImportBVMDataFromAPI]  
 @pType int =4 
   
AS  
BEGIN  
   DECLARE @StartDateTime varchar(50)  
   Declare @b as varchar(50)  
   DECLARE @i INTEGER;  
  
--**************** Daily call begins  
 if(@pType=1)  
 Begin  
  set @b =(select FORMAT ( DATEADD(day, -1,GETDATE()), 'dd-MM-yyyy') as date);  
   --  Declare @a as varchar(50)=Concat(@b,' 00:00:00')  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
    
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime , @pType=1;  
RETURN  ;  
 END  
  
--**************** Daily call ends  
  
--**************** Weekly call starts  
else if(@pType=2)  
 Begin  
DECLARE @WeeklyStart DATETIME;  
Set @WeeklyStart=(SELECT  GETDATE()-DAY(GETDATE())+1 AS FIRST_DAY_OF_DATE);  
   SET @i =0;  
   WHILE @i < 7  
   BEGIN  
      set @b= (select FORMAT ( DATEADD(day, @i,@WeeklyStart), 'dd-MM-yyyy') as date);  
   --  Declare @a as varchar(50)=Concat(@b,' 00:00:00')  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
    
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime,@pType=@pType;  
      SET @i = @i + 1;  
   END;  
  
   RETURN;  
 End  
--**************** Weekly call ends  
  
--**************** BiWeekly call starts  
else if(@pType=3)  
 Begin  
DECLARE @BiWeeklyStart DATETIME;  
Set @BiWeeklyStart=(SELECT  GETDATE()-DAY(GETDATE())+8 AS FIRST_DAY_OF_DATE);  
   SET @i = 0;  
   WHILE @i < 7  
   BEGIN  
      set @b= (select FORMAT ( DATEADD(day, @i,@BiWeeklyStart), 'dd-MM-yyyy') as date);  
   --  Declare @a as varchar(50)=Concat(@b,' 00:00:00')  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
    
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime,@pType=@pType;  
      SET @i = @i + 1;  
   END;  
  
   RETURN;  
 End  
--**************** BiWeekly call ends  
  
--**************** TriWeekly call starts  
else if(@pType=4)  
 Begin  
DECLARE @TriWeeklyStart DATETIME;  
Set @TriWeeklyStart=(SELECT  GETDATE()-DAY(GETDATE())+15 AS FIRST_DAY_OF_DATE);  
   SET @i = 0;  
   WHILE @i < 7  
   BEGIN  
      set @b= (select FORMAT ( DATEADD(day, @i,@TriWeeklyStart), 'dd-MM-yyyy') as date);  
   --  Declare @a as varchar(50)=Concat(@b,' 00:00:00')  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
    
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime,@pType=@pType;  
      SET @i = @i + 1;  
   END;  
  
   RETURN;  
 End  
--**************** TriWeekly call ends  
  
--**************** TetraWeekly call starts  
else if(@pType=8)  
 Begin  
DECLARE @TetraWeeklyStart DATETIME;  
Set @TetraWeeklyStart=(SELECT  DATEADD(Month,-1,GETDATE())-DAY(GETDATE())+22 AS FIRST_DAY_OF_DATE);  
   SET @i = 0;  
   WHILE @i < 7  
   BEGIN  
      set @b= (select FORMAT ( DATEADD(day, @i,@TetraWeeklyStart), 'dd-MM-yyyy') as date);  
   --  Declare @a as varchar(50)=Concat(@b,' 00:00:00')  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
    
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime,@pType=@pType;  
      SET @i = @i + 1;  
   END;  
  
   RETURN;  
 End  
--**************** TetraWeekly call ends  
  
--**************** Monthly call starts  
else if(@pType=5)  
  
 Begin  
 Print 'case 5 '  
 DECLARE @PreviousMonth datetime=(select  DATEADD(Month, -1,GETDATE()));  
 DECLARE @EndingDateofMonth datetime=(select EOMONTH(DATEADD(Month, -1,GETDATE())));  
 DECLARE @totalDays int=(SELECT DAY(EOMONTH(@PreviousMonth)) AS DaysInMonth);  
  
   SET @i =@totalDays;  
   WHILE @i > 0  
   BEGIN  
--   PRint 'date difference ' + (@totalDays-@i+1);  
      set @b= (select FORMAT ( DATEADD(day, -@totalDays+@i,@EndingDateofMonth), 'dd-MM-yyyy') as date);  
    set @StartDateTime= Concat(@b,' 00:00:00');  
  
  print @StartDateTime  
     EXEC [dbo].[ImportBVMDataFromAPI] @pDate=@StartDateTime,@pType=@pType;  
      SET @i = @i - 1;  
   END;  
  
   RETURN;  
 End  
--**************** Monthly call ends  
  
  
  
END  
  
  
