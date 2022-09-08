/****** Object:  Procedure [dbo].[ImportMeterDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 10 March 2022
--Comments : Import Meters Data From API
--======================================================================
--Truncate Table [dbo].[InterfaceRuCdpMeters]
-- Select * from [dbo].[InterfaceRuCdpMeters]
-- [dbo].[ImportMeterDataFromAPI]

CREATE PROCEDURE [dbo].[ImportMeterDataFromAPI]

AS
BEGIN

DECLARE @Object AS INT;
DECLARE @ResponseText AS NVARCHAR(max);
Declare @json as table(Json_Table nvarchar(max))
DECLARE @Body AS NVARCHAR(max) 

SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getMeterMasterData'

EXEC sp_OACREATE 'MSXML2.ServerXMLHttp', @Object OUT;

EXEC sp_OAMethod @Object, 'Open', NULL, 'POST', 'https://meter.ntdc.com.pk/MetersStatusP/CPPARestAPI', 'false'
EXEC sp_OAMethod @Object, 'SETRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded'

EXEC sp_OAMethod @Object, 'Send', null, @Body

INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'
select * from @json
---------------------------------------------------------------------------------------
-------------------	Insert into CDP Detail Interface table
---------------------------------------------------------------------------------------
TRUNCATE table InterfaceRuCdpMeters

drop TABLE if EXISTS #temp

SELECT          b.cdpId , b.meterId ,  CONVERT(decimal(18,0), CAST( b.meterNo AS FLOAT)) as  meterNo , b.status  , b.meterQualifier , b.meterModelType , b.lat , b.lng   , b.meterType , b.effectiveFrom  , b.effectiveTo , b.createdDateTime  , b.cdpUpdateTimestamp 

into #temp
FROM OPENJSON((SELECT * FROM @json))  
WITH
        (
            meterMasterDataBeans NVARCHAR(MAX) AS JSON
        ) AS a
		CROSS APPLY
    OPENJSON(a.meterMasterDataBeans)
    WITH
        (
        cdpId  decimal(18,0),
        meterId decimal(18,0),
		meterNo NVARCHAR(MAX), 
		status nvarchar(50),
		meterQualifier nvarchar(500),
		meterModelType  nvarchar(500),
		lat NVARCHAR(MAX),
		lng NVARCHAR(MAX),
		meterType NVARCHAR(MAX) ,
		effectiveFrom NVARCHAR(50),
		effectiveTo NVARCHAR(50),
		createdDateTime NVARCHAR(50),
		cdpUpdateTimestamp NVARCHAR(50)
			) AS b

--			select * from #temp
--return

DROP TABLE if EXISTS #temp1

			select           cdpId , meterId , meterNo , status  , meterQualifier , meterModelType , lat , lng   , meterType ,
--			CAST(Replace(effectiveFrom,'T',' ') as DATETIME) as effectiveFrom   , 			
			CAST(Replace(Replace(effectiveFrom,'<EMPTY/>',null),'T',' ') as DATETIME) as effectiveFrom   , 
			CAST(Replace(Replace(effectiveTo,'<EMPTY/>',null),'T',' ') as DATETIME) as effectiveTo   , 
			CAST(Replace(Replace(createdDateTime,'<EMPTY/>',null),'T',' ') as DATETIME) as createdDateTime   , 
			CAST(Replace(Replace(cdpUpdateTimestamp,'<EMPTY/>',null),'T',' ') as DATETIME) as cdpUpdateTimestamp   
			--CAST(Replace(effectiveTo,'<EMPTY/>',null) as DATETIME) as effectiveTo ,
			--CAST(Replace(createdDateTime ,'',null) as DATETIME) as createdDateTime  , 
			--CAST(Replace(cdpUpdateTimestamp ,'<EMPTY/>',null) as DATETIME) as cdpUpdateTimestamp ,
			--1 as sd
			
			into #temp1 from #temp


INSERT INTO [dbo].[InterfaceRuCdpMeters]
           ([InterfaceRuCdpMeters_MeterId]
           ,[InterfaceRuCDPDetail_CdpId]
           ,[InterfaceRuCdpMeters_MeterNo]
           ,[InterfaceRuCdpMeters_Status]
           ,[InterfaceRuCdpMeters_MeterQualifier]
           ,[InterfaceRuCdpMeters_MeterModelType]
           ,[InterfaceRuCdpMeters_Latitude]
           ,[InterfaceRuCdpMeters_Longitude]
           ,[InterfaceRuCdpMeters_MeterType]
           ,[InterfaceRuCdpMeters_EffectiveFrom]
           ,[InterfaceRuCdpMeters_EffectiveTo]
           ,[InterfaceRuCdpMeters_CreatedDateTime]
           ,[InterfaceRuCdpMeters_UpdatedDateTime]
           ,[InterfaceRuCdpMeters_CreatedOn]
           ,[InterfaceRuCdpMeters_IsDeleted])

		   SELECT meterId ,  cdpId ,  meterNo , status  , meterQualifier , meterModelType , lat , lng   , meterType , effectiveFrom  , effectiveTo , createdDateTime  , cdpUpdateTimestamp , GETUTCDATE(),0 from #temp1
Exec [dbo].[ImportandUpdateInMMSRuCdpMeter]

END
