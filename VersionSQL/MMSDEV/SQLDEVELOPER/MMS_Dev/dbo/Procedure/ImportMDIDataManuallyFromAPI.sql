/****** Object:  Procedure [dbo].[ImportMDIDataManuallyFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 24 Jun 2022
--Comments : Import MDI Data From API
--======================================================================
--   [dbo].[ImportMDIDataManuallyFromAPI] 3,2022

CREATE PROCEDURE [dbo].[ImportMDIDataManuallyFromAPI]
@Month as Int,
@Year as Int
AS
BEGIN


DECLARE @Object AS INT;
DECLARE @ResponseText AS NVARCHAR(max);
Declare @json as table(Json_Table nvarchar(max))
DECLARE @Body AS NVARCHAR(max) 
DECLARE @totalRows int;
DECLARE @startTime DATETIME;
DECLARE @endTime DATETIME;
DECLARE @timediff INT;
DECLARE @Notes varchar(200);

 --DECLARE @PreviousMonth int=(select DatePart(month,  DATEADD(Month, -1,GETDATE())));  
 --DECLARE @CurrentYear int=(select DatePart(year,  GETDATE()));  
 DECLARE @StartingDateofMonth datetime=(select DATEFROMPARTS(@Year, @Month,1));  
 DECLARE @EndingDateofMonth datetime=(select EOMONTH(@StartingDateofMonth));  

  Declare @ApiStartDate varchar(50) =(select FORMAT (@StartingDateofMonth, 'dd-MM-yyyy') as date);  
    set @ApiStartDate= Concat(@ApiStartDate,' 00:00:00');  

	  Declare @ApiEndDate varchar(50) =(select FORMAT (@EndingDateofMonth, 'dd-MM-yyyy') as date);  
    set @ApiEndDate= Concat(@ApiEndDate,' 00:00:00');  

SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getBVMMonthlyMDI&start_time='+@ApiStartDate+'&end_time='+@ApiEndDate

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

TRUNCATE table InterfaceMtMonthlyMDI

drop TABLE if EXISTS #temp

SELECT 
b.cdpId ,

convert(VARCHAR,  b.dateImportTimeStamp, 105) as dateImportTimeStamp, 
CONVERT(DECIMAL(18,4), CAST(b.mdiMonthImport AS FLOAT)) as mdiMonthImport
, b.iMeterId, 
b.iMeterQualifier , 
b.iMeterDataSource ,
b.iDataStatus,
b.iDataLabel ,

convert(VARCHAR,  b.dateExportTimeStamp, 105) as dateExportTimeStamp, 
CONVERT(DECIMAL(18,4), CAST(b.mdiMonthExport AS FLOAT)) as mdiMonthExport
, b.eMeterId, 
b.eMeterQualifier , 
b.eMeterDataSource ,
b.eDataStatus,
b.eDataLabel 
 into #temp
FROM OPENJSON((SELECT * FROM @json))  
WITH
        (
            bvmMonthlyMDIBeans NVARCHAR(MAX) AS JSON
        ) AS a
		CROSS APPLY
    OPENJSON(a.bvmMonthlyMDIBeans)
    WITH
        (
		cdpId int
		,mdiMonthImport NVARCHAR(MAX)
		,dateImportTimeStamp nvarchar(50)
		,iMeterId  decimal(18,0)
		,iMeterQualifier NVARCHAR(MAX)
		,iMeterDataSource NVARCHAR(MAX)
		,iDataStatus NVARCHAR(MAX)
		,iDataLabel NVARCHAR(MAX)
		,mdiMonthExport NVARCHAR(MAX)
		,dateExportTimeStamp nvarchar(50)
		,eMeterId decimal(18,0)
		,eMeterQualifier NVARCHAR(MAX)
		,eMeterDataSource NVARCHAR(MAX)
		,eDataStatus NVARCHAR(MAX)
		,eDataLabel NVARCHAR(MAX)
			) AS b

INSERT INTO [dbo].[InterfaceMtMonthlyMDI]
           ([RuCDPDetail_CdpId]
           ,[InterfaceMtMonthlyMDI_Month]
           ,[InterfaceMtMonthlyMDI_Year]
           ,[InterfaceMtMonthlyMDI_DateTimeStampImport]
           ,[InterfaceMtMonthlyMDI_MdiMonthImport]
           ,[InterfaceMtMonthlyMDI_MeterIdImport]
           ,[InterfaceMtMonthlyMDI_DataSourceImport]
           ,[InterfaceMtMonthlyMDI_MeterQualifierImport]
           ,[InterfaceMtMonthlyMDI_DataLabelImport]
           ,[InterfaceMtMonthlyMDI_DataStatusImport]
           ,[InterfaceMtMonthlyMDI_DateTimeStampExport]
           ,[InterfaceMtMonthlyMDI_MdiMonthExport]
           ,[InterfaceMtMonthlyMDI_MeterIdExport]
           ,[InterfaceMtMonthlyMDI_DataSourceExport]
           ,[InterfaceMtMonthlyMDI_MeterQualifierExport]
           ,[InterfaceMtMonthlyMDI_DataLabelExport]
           ,[InterfaceMtMonthlyMDI_DataStatusExport]
           ,[InterfaceMtMonthlyMDI_CreatedOn]
           ,[InterfaceMtMonthlyMDI_IsDeleted])

		select  
		cdpId ,
		@Month,
		@Year,
	 case when (dateImportTimeStamp is not NULL AND dateImportTimeStamp <>'') then convert(DATETIME, dateImportTimeStamp,105) else null end,
--		convert(DATETIME,dateImportTimeStamp,105),
		mdiMonthImport, 
		iMeterId,
		iMeterDataSource,
		iMeterQualifier,
		iDataLabel,
		iDataStatus,
	 case when (dateExportTimeStamp is not NULL AND dateExportTimeStamp <>'') then convert(DATETIME, dateExportTimeStamp,105) else null end,
--		convert(DATETIME,dateExportTimeStamp,105),
		mdiMonthExport, 
		eMeterId,
		eMeterDataSource,
		eMeterQualifier,
		eDataLabel,
		eDataStatus,
		GetUTCDate()
		,0	
	from #temp


select @totalRows=count(1) from #temp
SET  @endTime=GETUTCDATE()
Declare @pType as int=1;
SET @timediff=DATEDIFF(SECOND,@startTime,@endTime)
Declare @DateOnly as varchar(20);
SELECT @DateOnly=LEFT(@EndingDateofMonth, 10);
SET @Notes = Concat('MDI api date:',@DateOnly) ;
execute InsertImportMeteringLogs 4,1,@pType,@Notes,@timediff,@totalRows

execute [dbo].[ImportandUpdateInMMSMtMDIMeter]


--Declare @TotalRecords as int=null;
--Declare @Percentage as int=null;
----select @TotalRecords=count(1) from MtBvmReading where  CAST(MtBvmReadingIntf_NtdcDateTime AS DATE) = CAST(@pDate AS DATE)
--select  @TotalRecords=count(1) from MtBvmReading where datediff(dd, MtBvmReadingIntf_NtdcDateTime, CONVERT(DATE,@pStartDate, 103)) = 0
--select @Percentage=(@TotalRecords * 100)/((select count(1) from RuCDPDetail)*24)

----UPDATE [dbo].[ImportMeteringLogs] set ImportMeteringLogs_Percentage=@Percentage where ImportMeteringLogs_Note=@Notes


END
