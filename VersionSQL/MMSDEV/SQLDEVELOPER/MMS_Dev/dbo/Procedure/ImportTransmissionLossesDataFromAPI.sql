/****** Object:  Procedure [dbo].[ImportTransmissionLossesDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 11 Jan 2023
--Comments : Import Transmission losses Data From API
--======================================================================
--  dbo.ImportTransmissionLossesDataFromAPI  @pStartDate='01-05-2023' ,@pEndDate='01-06-2023', @pType=5
--select * from [dbo].[InterfaceMtTransmissionLosses]
--truncate table [dbo].[InterfaceMtTransmissionLosses]
CREATE   PROCEDURE dbo.ImportTransmissionLossesDataFromAPI
@pStartDate varchar(50) =null,
@pEndDate varchar(50) =null,
 @pType int=null
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

SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getHalfHourlyTranmissionLosses&start_time='+@pStartDate+'&end_time='+@pEndDate

SET  @startTime=GETUTCDATE()

print @Body
EXEC sp_OACREATE 'MSXML2.ServerXMLHttp', @Object OUT;

EXEC sp_OAMethod @Object, 'Open', NULL, 'POST', 'https://meter.ntdc.com.pk/MetersStatusP/CPPARestAPI', 'false'
EXEC sp_OAMethod @Object, 'SETRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded'

EXEC sp_OAMethod @Object, 'Send', null, @Body


INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'
--select * from @json
---------------------------------------------------------------------------------------
-------------------	Insert into MtTransmission Losses Interface table
---------------------------------------------------------------------------------------

drop TABLE if EXISTS #temp_AP2

SELECT 
convert(VARCHAR,  b.recordTime, 105) as recordTime 
,tspName
,CONVERT(DECIMAL(18,4), CAST(b.importMWh AS FLOAT)) as importMWh
,CONVERT(DECIMAL(18,4), CAST(b.exportMWh AS FLOAT)) as exportMWh
,CONVERT(DECIMAL(18,4), CAST(b.tranmissionLossMWh AS FLOAT)) as tranmissionLossMWh
 into #temp_AP2
FROM OPENJSON((SELECT * FROM @json))  
WITH
        (
            hourlyLossesBeans NVARCHAR(MAX) AS JSON
        ) AS a
		CROSS APPLY
    OPENJSON(a.hourlyLossesBeans)
    WITH
        (
		recordTime nvarchar(50),
		tspName NVARCHAR(MAX),
		importMWh NVARCHAR(MAX),
		exportMWh NVARCHAR(MAX),
		tranmissionLossMWh NVARCHAR(MAX)
			) AS b


--select * from #temp_AP2

INSERT INTO [dbo].[InterfaceMtTransmissionLosses]
           (
		   [InterfaceMtTransmissionLosses_NtdcDateTime]
		   ,[InterfaceMtTransmissionLosses_TspName] 
		   ,[InterfaceMtTransmissionLosses_importMWh] 
		   ,[InterfaceMtTransmissionLosses_exportMWh] 
		   ,[InterfaceMtTransmissionLosses_tranmissionLossMWh]
		   ,[InterfaceMtTransmissionLosses_CreatedOn] 
		   ,[InterfaceMtTransmissionLosses_IsDeleted] 
		   )

		select 
		convert(DATETIME,recordTime,105)
		,tspName 
		,importMWh
		,exportMWh
		,tranmissionLossMWh 
		, GETUTCDATE(),0 from #temp_AP2

SET  @endTime=GETUTCDATE()
select @totalRows=count(1) from #temp_AP2
SET  @endTime=GETUTCDATE()
SET @timediff=DATEDIFF(SECOND,@startTime,@endTime)


Declare @DateOnly as varchar(20);
SELECT @DateOnly=LEFT(@pStartDate, 10);
SET @Notes = Concat('api date:',@DateOnly) ;

execute InsertImportMeteringLogs 5,1,@pType,@Notes,@timediff,@totalRows;


execute [dbo].[ImportInMMSMeteringTransmissionLosses] 

END
