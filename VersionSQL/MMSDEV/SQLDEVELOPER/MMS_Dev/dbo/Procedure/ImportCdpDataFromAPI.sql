/****** Object:  Procedure [dbo].[ImportCdpDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

  
--======================================================================  
--Author  : Sadaf Malik  
--Reviewer : <>  
--CreatedDate : 10 March 2022  
--Comments : Import CDP Data From API  
--======================================================================  
  
CREATE PROCEDURE [dbo].[ImportCdpDataFromAPI]  
  
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
  
SET  @startTime=GETUTCDATE()  
  
SET @Body = 'api_key=4babdd93-cf6f-4445-9334-c141457c3c8c&action=getCDPMasterData'  
  
EXEC sp_OACREATE 'MSXML2.ServerXMLHttp', @Object OUT;  
  
EXEC sp_OAMethod @Object, 'Open', NULL, 'POST', 'https://meter.ntdc.com.pk/MetersStatusP/CPPARestAPI', 'false'  
EXEC sp_OAMethod @Object, 'SETRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded'  
  
--EXEC sp_OAMethod @Object, 'SETRequestBody', null, 'Body', @Body  
  
EXEC sp_OAMethod @Object, 'Send', null, @Body  
  
--INSERT INTO @tableResponseText ([ResponseText]) EXEC sp_OAGetProperty @Object, 'responseText'  
--select * from @tableResponseText  
  
INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'  
  
--select * from @json  
---------------------------------------------------------------------------------------  
------------------- Insert into CDP Detail Interface table  
---------------------------------------------------------------------------------------  
TRUNCATE table dbo.InterfaceRuCDPDetail  
  
drop TABLE if EXISTS #temp  
  
--delete from @json  
SELECT  b.cdpId ,b.cdpName,b.cdpStatus,b.effectiveFrom , b.effectiveTo ,b.station,b.stationType, b.lineVoltage, b.fromCustomer, b.toCustomer
into #temp  
FROM OPENJSON((SELECT * FROM @json))    
WITH  
        (  
            cdpMasterDataBeans NVARCHAR(MAX) AS JSON  
        ) AS a  
  CROSS APPLY  
    OPENJSON(a.cdpMasterDataBeans)  
    WITH  
        (  
        cdpId int,  
  cdpName nvarchar(50),   
  cdpStatus nvarchar(50),  
  effectiveFrom nvarchar(50),  
  effectiveTo  nvarchar(50),
  lineVoltage nvarchar(20),
  fromCustomer nvarchar(50),
  toCustomer nvarchar(50),
  station  nvarchar(50),  
  stationType NVARCHAR(MAX)   
   ) AS b  

  

DROP TABLE if EXISTS #temp1  
  
--   select    cdpId ,cdpName,cdpStatus,CAST(Replace(effectiveFrom,'T',' ') as DATETIME)as effectiveFrom ,CAST(Replace(Replace(effectiveTo,'<EMPTY/>',null),'T',' ')  as DATETIME) as effectiveTo,station,stationType, lineVoltage, fromCustomer, toCustomer  into #temp1 from #temp  
  
     select    cdpId ,cdpName,cdpStatus,CAST(Replace(Replace(effectiveFrom,'<EMPTY/>',''),'T',' ')  as DATETIME)as effectiveFrom ,CAST(Replace(Replace(effectiveTo,'<EMPTY/>',''),'T',' ')  as DATETIME) as effectiveTo,station,stationType,
--	 CAST(Replace(lineVoltage,'<NULL/>',null) as Decimal) as  
	 lineVoltage, fromCustomer, toCustomer  into #temp1 from #temp  


select * from #temp1  
  
INSERT INTO [dbo].[InterfaceRuCDPDetail]  
           ([InterfaceRuCDPDetail_CdpId]  
           ,[InterfaceRuCDPDetail_CdpName]  
           ,[InterfaceRuCDPDetail_CdpStatus]  
           ,[InterfaceRuCDPDetail_EffectiveFrom]  
           ,[InterfaceRuCDPDetail_EffectiveTo]  
           ,[InterfaceRuCDPDetail_Station]
		   ,[InterfaceRuCDPDetail_LineVoltage]
		   ,[InterfaceRuCDPDetail_FromCustomer]
		   ,[InterfaceRuCDPDetail_ToCustomer]
           ,[InterfaceRuCDPDetail_CreatedOn]  
           ,[InterfaceRuCDPDetail_IsDeleted])  
      
     SELECT cdpId ,cdpName, cdpStatus, 
	 	 case when effectiveFrom='1900-01-01 00:00:00.000' then null else	 effectiveFrom end as effectiveFrom	 ,
	 	 case when effectiveTo='1900-01-01 00:00:00.000' then null else	 effectiveTo end as effectiveTo	 ,
		station,
	 case when lineVoltage='<NULL/>' then null else	 lineVoltage end, 
	-- lineVoltage,
	 fromCustomer, toCustomer, GETUTCDATE(),0 from #temp1  
     where cdpId is NOT NULL

  
EXEC [dbo].[ImportandUpdateInMMSCdpDetail]  
select @totalRows=count(1) from #temp1  
SET  @endTime=GETUTCDATE()  
  
  
SET  @endTime=GETUTCDATE()  
SET @timediff=DATEDIFF(SECOND,@startTime,@endTime)  
Declare @Notes as varchar(50)= 'api date:'+(select FORMAT ( GetDate(), 'dd-MM-yyyy') as date);  
execute InsertImportMeteringLogs 2,1,6,@Notes,@timediff,@totalRows  
  
END  
