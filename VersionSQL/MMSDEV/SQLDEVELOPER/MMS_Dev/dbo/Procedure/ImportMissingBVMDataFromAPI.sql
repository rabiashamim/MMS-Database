/****** Object:  Procedure [dbo].[ImportMissingBVMDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 11 March 2022
--Comments : Import BVM Data From API
--======================================================================
--  [dbo].[ImportBVMDataFromAPI] @pDate='29-05-2022' , @pType=1
--select * from InterfaceMtBvmReading
--truncate table InterfaceMtBvmReading
--[dbo].[ImportMissingBVMDataFromAPI] 11
CREATE PROCEDURE [dbo].[ImportMissingBVMDataFromAPI]

 @pType int=null
AS
BEGIN



--DECLARE @pStartDate varchar(50)=null   ,
--@pEndDate varchar(50)=null 
 


DECLARE @Object AS INT;
DECLARE @ResponseText AS NVARCHAR(max);
Declare @json as table(Json_Table nvarchar(max))
DECLARE @Body AS NVARCHAR(max) 
DECLARE @totalRows int;
DECLARE @startTime DATETIME;
DECLARE @endTime DATETIME;
DECLARE @timediff INT;
DECLARE @Notes varchar(200);


 DECLARE @PreviousMonth int=(select DatePart(month,  DATEADD(Month, -2,GETDATE())));  
 DECLARE @CurrentYear int=(select DatePart(year,  GETDATE()));  
 DECLARE @EndingDateofMonth datetime=(select EOMONTH(DATEADD(Month, -2,GETDATE())));  
 DECLARE @StartingDateofMonth datetime=(select DATEFROMPARTS(DATEPART(year, GETDATE()), @PreviousMonth,1));  

--set @StartingDateofMonth='2022-06-30 00:00:00';
 --set @EndingDateofMonth='2022-07-01 00:00:00';
 set @EndingDateofMonth=DATEADD(day,1, @EndingDateofMonth)
   Declare @ApiStartDate varchar(50) =(select FORMAT (@StartingDateofMonth, 'dd-MM-yyyy') as date);  
    set @ApiStartDate= Concat(@ApiStartDate,' 00:00:00');  

	  Declare @ApiEndDate varchar(50) =(select FORMAT (@EndingDateofMonth, 'dd-MM-yyyy') as date);  
    set @ApiEndDate= Concat(@ApiEndDate,' 00:00:00');  


SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getMissingBVMMeteringDataHalfHourly&start_time='+@ApiStartDate+'&end_time='+@ApiEndDate

--SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getBVMMeteringDataHalfHourly&start_time=01-01-2022 00:30:30&end_time=01-01-2022 00:30:30'
SET  @startTime=GETUTCDATE()

print @Body
EXEC sp_OACREATE 'MSXML2.ServerXMLHttp', @Object OUT;

EXEC sp_OAMethod @Object, 'Open', NULL, 'POST', 'https://meter.ntdc.com.pk/MetersStatusP/CPPARestAPI', 'false'
EXEC sp_OAMethod @Object, 'SETRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded'

EXEC sp_OAMethod @Object, 'Send', null, @Body


INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'
select * from @json
---------------------------------------------------------------------------------------
-------------------	Insert into CDP Detail Interface table
---------------------------------------------------------------------------------------

--TRUNCATE table InterfaceMtBvmReading

drop TABLE if EXISTS #temp

SELECT convert(VARCHAR,  b.dateTimeStamp, 105) as dateTimeStamp, b.cdpId 
,CONVERT(DECIMAL(18,4), CAST(b.incrementalActiveEnergyImport AS FLOAT)) as incrementalActiveEnergyImport
, b.iMeterId, b.iMeterQualifier , b.iMeterDataSource , b.iDataStatus, b.iLabel ,
CONVERT(DECIMAL(18,4), CAST(b.incrementalActiveEnergyExport AS FLOAT)) as incrementalActiveEnergyExport,
b.eMeterId, b.eMeterQualifier , b.eMeterDataSource, b.eDataStatus, b.eLabel 
 into #temp
FROM OPENJSON((SELECT * FROM @json))  
WITH
        (
            missingBvmMeteringDataHalfHourlyBeans NVARCHAR(MAX) AS JSON
        ) AS a
		CROSS APPLY
    OPENJSON(a.missingBvmMeteringDataHalfHourlyBeans)
    WITH
        (
		dateTimeStamp nvarchar(50),
		cdpId int,
		incrementalActiveEnergyImport NVARCHAR(MAX),
		iMeterId decimal(18,0),
		iMeterQualifier NVARCHAR(MAX),
		iMeterDataSource NVARCHAR(MAX),
		iDataStatus NVARCHAR(MAX),
		iLabel NVARCHAR(MAX),
		incrementalActiveEnergyExport NVARCHAR(MAX),
		eMeterId decimal(18,0),
		eMeterQualifier NVARCHAR(MAX),
		eMeterDataSource NVARCHAR(MAX),
		eDataStatus NVARCHAR(MAX),
		eLabel NVARCHAR(MAX)
			) AS b


select * from #temp

INSERT INTO [dbo].[InterfaceMtBvmReading]
           ([InterfaceMtBvmReadingIntf_NtdcDateTime]
           ,[InterfaceRuCDPDetail_CdpId]
           ,[InterfaceRuCdpMeters_MeterIdImport]
           ,[InterfaceMtBvmReading_IncEnergyImport]
           ,[InterfaceMtBvmReading_DataSourceImport]
		   ,[InterfaceMtBvmReading_MeterQualifierImport]
           ,[InterfaceMtBvmReading_DataLabelImport]
           ,[InterfaceMtBvmReading_DataStatusImport]
			,[InterfaceRuCdpMeters_MeterIdExport]
           ,[InterfaceMtBvmReading_IncEnergyExport]
           ,[InterfaceMtBvmReading_DataSourceExport]
		   ,[InterfaceMtBvmReading_MeterQualifierExport]
           ,[InterfaceMtBvmReading_DataLabelExport]
           ,[InterfaceMtBvmReading_DataStatusExport]
           ,[InterfaceMtBvmReading_CreatedOn]
           ,[InterfaceMtBvmReading_IsDeleted])

		select convert(DATETIME,dateTimeStamp,105) as dd	, cdpId ,iMeterId, incrementalActiveEnergyImport, iMeterDataSource ,  iMeterQualifier ,iLabel , iDataStatus,  eMeterId, incrementalActiveEnergyExport , eMeterDataSource, eMeterQualifier , eLabel , eDataStatus, GETUTCDATE(),0 from #temp

SET  @endTime=GETUTCDATE()
select @totalRows=count(1) from #temp
SET  @endTime=GETUTCDATE()


SET  @endTime=GETUTCDATE()
SET @timediff=DATEDIFF(SECOND,@startTime,@endTime)
Declare @DateOnly as varchar(20);
--SELECT @DateOnly=LEFT(@pDate, 10);
SET @Notes ='Monthly API Call for Missing values';
execute InsertImportMeteringLogs 3,1,@pType,@Notes,@timediff,@totalRows

--execute [dbo].[ImportInMMSMeteringBVMData]  


Declare @TotalRecords as int=null;
Declare @Percentage as int=null;
--select @TotalRecords=count(1) from MtBvmReading where  CAST(MtBvmReadingIntf_NtdcDateTime AS DATE) = CAST(@pDate AS DATE)
--select  @TotalRecords==count(1) from MtBvmReading where datediff(dd, MtBvmReadingIntf_NtdcDateTime, CONVERT(DATE,@pDate, 103)) = 0
select @TotalRecords=count(1) from #temp

select @Percentage=(@TotalRecords * 100)/((select count(1) from RuCDPDetail)*24)

--UPDATE [dbo].[ImportMeteringLogs] set ImportMeteringLogs_Percentage=@Percentage where ImportMeteringLogs_Note=@Notes


END
