/****** Object:  Procedure [dbo].[NTDCImportMonthlyMeteringDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[NTDCImportMonthlyMeteringDataFromAPI]
@Month int =6,
@year as int=2022,
 @pType int=5
AS
BEGIN

Truncate table InterfaceMtBVMReading;

/*********************************************************************************************
		Import Monthly Metering Data
****************************************************************************************/
 DECLARE @StartDateTime varchar(50)  
 DECLARE @EndDateTime varchar(50)  
   Declare @StartingDateOfApi as varchar(50)  
   Declare @EndingDatOfApi as varchar(50)  
   DECLARE @i INTEGER;  

Declare @StartingDateOfMonth datetime=(select DATEFROMPARTS( @year,@Month,1));
 DECLARE @EndingDateofMonth datetime=  (select EOMONTH(@StartingDateOfMonth));  
 DECLARE @totalDays int=(SELECT DAY(EOMONTH(@StartingDateOfMonth)) AS DaysInMonth);  

   SET @i =@totalDays;  
   WHILE @i > 0  
   BEGIN  

      set @EndingDatOfApi= (select FORMAT ( DATEADD(day, -@totalDays+@i+1,@EndingDateofMonth), 'dd-MM-yyyy') as date);  
      set @StartingDateOfApi= (select FORMAT ( DATEADD(day, -@totalDays+@i,@EndingDateofMonth), 'dd-MM-yyyy') as date);  
    set @StartDateTime= Concat(@StartingDateOfApi,' 00:01:00');  
  set @EndDateTime=Concat(@EndingDatOfApi,' 00:00:00');  
  print 'Start Date: '+@StartDateTime  
print  'End Date: '+@EndDateTime  
     EXEC [dbo].[ImportBVMDataFromAPI2] @pStartDate=@StartDateTime,@pEndDate=@EndDateTime,@pType=@pType;  
      SET @i = @i - 1;  
   END;  
return;

/****************************************************************************************
				Import Adjustments Data
******************************************************************************************/ 

DECLARE @Object AS INT;
DECLARE @ResponseText AS NVARCHAR(max);
Declare @json as table(Json_Table nvarchar(max))
DECLARE @Body AS NVARCHAR(max) 
DECLARE @totalRows int;
DECLARE @startTime DATETIME;
DECLARE @endTime DATETIME;
DECLARE @timediff INT;
DECLARE @Notes varchar(200);


 set @EndingDateofMonth=DATEADD(day,1, @EndingDateofMonth)
   Declare @ApiStartDate varchar(50) =(select FORMAT (@StartingDateofMonth, 'dd-MM-yyyy') as date);  
    set @ApiStartDate= Concat(@ApiStartDate,' 00:01:00');  

	  Declare @ApiEndDate varchar(50) =(select FORMAT (@EndingDateofMonth, 'dd-MM-yyyy') as date);  
    set @ApiEndDate= Concat(@ApiEndDate,' 00:00:00');  


SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getMissingBVMMeteringDataHalfHourly&start_time='+@ApiStartDate+'&end_time='+@ApiEndDate

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


drop TABLE if EXISTS #temp

SELECT 

 ROW_NUMBER() over(order by  b.cdpId )as rn,
convert(VARCHAR,  b.dateTimeStamp, 105) as dateTimeStamp, b.cdpId 
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

	--		return;

--			select count(1) from #temp
DROP TABLE IF EXISTS #alreadyExists
DROP TABLE IF EXISTS #tempNewRecord



SELECT  t.rn,
BVM.InterfaceMtBvmReading_Id
, BVM.[InterfaceRuCDPDetail_CdpId]
,BVM.[InterfaceMtBvmReadingIntf_NtdcDateTime], t.incrementalActiveEnergyImport,t.incrementalActiveEnergyExport 
INTO #alreadyExists
from #temp t
JOIN [dbo].[InterfaceMtBvmReading] BVM 
ON convert(DATETIME,t.dateTimeStamp,105)=BVM.[InterfaceMtBvmReadingIntf_NtdcDateTime]
AND BVM.[InterfaceRuCDPDetail_CdpId]=t.cdpId




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

		select convert(DATETIME,dateTimeStamp,105) as dd	, cdpId ,iMeterId, incrementalActiveEnergyImport, iMeterDataSource
		,  iMeterQualifier ,iLabel , iDataStatus,  eMeterId, incrementalActiveEnergyExport , eMeterDataSource, eMeterQualifier , eLabel , eDataStatus, GETUTCDATE(),0 
		from #temp
		WHERE rn NOT IN (
		SELECT rn FROM #alreadyExists 
		)



  UPDATE BVM SET
  BVM.InterfaceMtBvmReading_IncEnergyImport=T.incrementalActiveEnergyImport
  ,BVM.InterfaceMtBvmReading_IncEnergyExport=T.incrementalActiveEnergyExport
  FROM  [dbo].[InterfaceMtBvmReading] BVM
  JOIN #alreadyExists t ON t.InterfaceMtBvmReading_Id = BVM.InterfaceMtBvmReading_Id


END
