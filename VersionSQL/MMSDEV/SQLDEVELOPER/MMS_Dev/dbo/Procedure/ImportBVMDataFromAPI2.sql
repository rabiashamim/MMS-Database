/****** Object:  Procedure [dbo].[ImportBVMDataFromAPI2]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 11 March 2022
--Comments : Import BVM Data From API
--======================================================================
--  [dbo].[ImportBVMDataFromAPI2] @pDate='11-06-2022' , @pType=1
--select * from InterfaceMtBvmReading
--truncate table InterfaceMtBvmReading
CREATE PROCEDURE [dbo].[ImportBVMDataFromAPI2]
@pStartDate varchar(50) =null,
@pEndDate varchar(50) =null,
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



-- if(@pType=1)
--BEGIN
--pRINT 'iF STARTED'
--		Declare @b as varchar(50)= (select FORMAT ( DATEADD(day, -1,GETDATE()), 'dd-MM-yyyy') as date);
--		Declare @a as varchar(50)=Concat(@b,' 00:30:30')

--	 SET @pStartDate =@a
--	 SET @pEndDate=@a

--END
--ELSE
--	Return

Declare @StartDate as varchar(20)=@pStartDate;
Declare @EndDate as varchar(20)=@pEndDate;

SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getBVMMeteringDataHalfHourly2&start_time='+@StartDate+'&end_time='+@EndDate

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

drop TABLE if EXISTS #temp_AP2

SELECT convert(VARCHAR,  b.dTS, 105) as dTS, b.cI 
,CONVERT(DECIMAL(18,4), CAST(b.iAI AS FLOAT)) as iAI
, b.iMI, b.iMQ , b.iMDS , b.iDS, b.iL ,
CONVERT(DECIMAL(18,4), CAST(b.iAE AS FLOAT)) as iAE,
b.eMI, b.eMQ , b.eMDS, b.eDS, b.eL 
 into #temp_AP2
FROM OPENJSON((SELECT * FROM @json))  
WITH
        (
            bvmMeteringDataHalfHourlyBeans NVARCHAR(MAX) AS JSON
        ) AS a
		CROSS APPLY
    OPENJSON(a.bvmMeteringDataHalfHourlyBeans)
    WITH
        (
		dTS nvarchar(50),
		cI int,
		iAI NVARCHAR(MAX),
		iMI NVARCHAR(MAX),
		iMQ NVARCHAR(MAX),
		iMDS NVARCHAR(MAX),
		iDS NVARCHAR(MAX),
		iL NVARCHAR(MAX),
		iAE NVARCHAR(MAX),
		eMI NVARCHAR(MAX),
		eMQ NVARCHAR(MAX),
		eMDS NVARCHAR(MAX),
		eDS NVARCHAR(MAX),
		eL NVARCHAR(MAX)
			) AS b


--select * from #temp_AP2

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

		select convert(DATETIME,dTS,105) as dd	, cI ,0--iMI
		, iAI, iMDS ,  iMQ ,iL , iDS,  0--eMI
		, iAE , eMDS, eMQ , eL , eDS, GETUTCDATE(),0 from #temp_AP2

SET  @endTime=GETUTCDATE()
select @totalRows=count(1) from #temp_AP2
SET  @endTime=GETUTCDATE()


SET  @endTime=GETUTCDATE()
SET @timediff=DATEDIFF(SECOND,@startTime,@endTime)
Declare @DateOnly as varchar(20);
SELECT @DateOnly=LEFT(@pStartDate, 10);
SET @Notes = Concat('api date:',@DateOnly) ;

execute InsertImportMeteringLogs 3,1,@pType,@Notes,@timediff,@totalRows;


--execute [dbo].[ImportInMMSMeteringBVMData]  


Declare @TotalRecords as int=null;
Declare @Percentage as int=null;
--select @TotalRecords=count(1) from MtBvmReading where  CAST(MtBvmReadingIntf_NtdcDateTime AS DATE) = CAST(@pDate AS DATE)
select  @TotalRecords=count(1) from MtBvmReading where datediff(dd, MtBvmReadingIntf_NtdcDateTime, CONVERT(DATE,@pStartDate, 103)) = 0
select @Percentage=(@TotalRecords * 100)/((select count(1) from RuCDPDetail)*24)

--UPDATE [dbo].[ImportMeteringLogs] set ImportMeteringLogs_Percentage=@Percentage where ImportMeteringLogs_Note=@Notes


END
