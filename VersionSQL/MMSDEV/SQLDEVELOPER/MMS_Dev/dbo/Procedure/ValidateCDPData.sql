/****** Object:  Procedure [dbo].[ValidateCDPData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 
-- exec [dbo].[ValidateCDPData]
CREATE PROCEDURE [dbo].[ValidateCDPData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
[RuCDPDetail_Id]
      ,[RuCDPDetail_CdpId]
      ,[RuCDPDetail_CdpName]
      ,[RuCDPDetail_CdpStatus]
      ,[RuCDPDetail_ToCustomer]
      ,[RuCDPDetail_FromCustomer]
      ,[IsAssigned]
      ,[RuCDPDetail_LineVoltage]
      ,[RuCDPDetail_Station]
      ,[RuCDPDetail_EffectiveFrom]
      ,[RuCDPDetail_EffectiveTo]
      ,[RuCDPDetail_CreatedDateTime]
      ,[RuCDPDetail_UpdatedDateTime]
      ,[RuCDPDetail_CreatedBy]
      ,[RuCDPDetail_CreatedOn]
      ,[RuCDPDetail_ModifiedBy]
      ,[RuCDPDetail_ModifiedOn]
      ,[RuCDPDetail_ConnectedFromID]
      ,[RuCDPDetail_ConnectedToID]
      ,[RuCDPDetail_EffectiveFromIPP]
      ,[RuCDPDetail_EffectiveToIPP]
      ,[RuCDPDetail_IsEnergyImported]
      ,[RuCDPDetail_TaxZoneID]
      ,[RuCDPDetail_CongestedZoneID]
      ,[RuCDPDetail_ToCustomerCategory]
      ,[RuCDPDetail_FromCustomerCategory]
      ,[RuCDPDetail_ConnectedFromCategoryID]
      ,[RuCDPDetail_ConnectedToCategoryID]
*/
DECLARE @COUNT_CDP INT=0;
--DECLARE @COUNT_NULL_CDP_ID INT=0;
--DECLARE @COUNT_NULL_CDP_NAME INT=0;
--DECLARE @COUNT_NULL_CDP_STATUS INT=0;
DECLARE @COUNT_NULL_EFFECTIVE_FROM INT=0;
--DECLARE @COUNT_NULL_EFFECTIVE_TO INT=0;
DECLARE @COUNT_NULL_CONNECTION_FROM_ID INT=0;
DECLARE @COUNT_NULL_CONNECTION_TO_ID INT=0;
--DECLARE @COUNT_NULL_CONNECTION_FROM_CATEGORY_ID INT=0;
--DECLARE @COUNT_NULL_CONNECTION_TO_CATEGORY_ID INT=0;
DECLARE @COUNT_NULL_CONNECTION_FROM_CATEGORY INT=0;
DECLARE @COUNT_NULL_CONNECTION_TO_CATEGORY INT=0;
DECLARE @COUNT_NULL_CONGESTED_ZONE_ID INT=0;
--DECLARE @COUNT_NULL_IS_ENERGY_IMPORTED INT=0;
--DECLARE @COUNT_NULL_IS_ASSIGNED INT=0;
DECLARE @COUNT_NULL_LINE_VOLTAGE INT=0;

   
select @COUNT_CDP = COUNT(1), 
       -- @COUNT_NULL_CDP_ID=SUM(CASE WHEN C.RuCDPDetail_CdpId is null THEN 1 ELSE 0 END),
       -- @COUNT_NULL_CDP_NAME=SUM(CASE WHEN C.RuCDPDetail_CdpName is null THEN 1 ELSE 0 END),
--@COUNT_NULL_CDP_STATUS=SUM(CASE WHEN C.RuCDPDetail_CdpStatus is null THEN 1 ELSE 0 END),
@COUNT_NULL_EFFECTIVE_FROM=SUM(CASE WHEN C.RuCDPDetail_EffectiveFrom is null THEN 1 ELSE 0 END),
--@COUNT_NULL_EFFECTIVE_TO=SUM(CASE WHEN C.RuCDPDetail_EffectiveTo is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONNECTION_FROM_ID=SUM(CASE WHEN C.RuCDPDetail_ConnectedFromID is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONNECTION_TO_ID=SUM(CASE WHEN C.RuCDPDetail_ConnectedToID is null THEN 1 ELSE 0 END),
--@COUNT_NULL_CONNECTION_FROM_CATEGORY_ID=SUM(CASE WHEN C.RuCDPDetail_ConnectedFromCategoryID is null THEN 1 ELSE 0 END),
--@COUNT_NULL_CONNECTION_TO_CATEGORY_ID=SUM(CASE WHEN C.RuCDPDetail_ConnectedToCategoryID is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONNECTION_FROM_CATEGORY=SUM(CASE WHEN C.RuCDPDetail_FromCustomerCategory is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONNECTION_TO_CATEGORY=SUM(CASE WHEN C.RuCDPDetail_ToCustomerCategory is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONGESTED_ZONE_ID=SUM(CASE WHEN C.RuCDPDetail_CongestedZoneID is null THEN 1 ELSE 0 END)--,
--@COUNT_NULL_IS_ENERGY_IMPORTED=SUM(CASE WHEN C.RuCDPDetail_IsEnergyImported is null THEN 1 ELSE 0 END),
--@COUNT_NULL_IS_ASSIGNED=SUM(CASE WHEN C.IsAssigned is null THEN 1 ELSE 0 END),
--@COUNT_NULL_LINE_VOLTAGE=SUM(CASE WHEN C.RuCDPDetail_LineVoltage is null THEN 1 ELSE 0 END)
        from RuCDPDetail C;

 
--SELECT @COUNT_CDP as COUNT_CDP,
----@COUNT_NULL_CDP_ID as COUNT_NULL_CDP_ID,
------@COUNT_NULL_CDP_NAME as COUNT_NULL_CDP_NAME,
----@COUNT_NULL_CDP_STATUS as COUNT_NULL_CDP_STATUS,
--@COUNT_NULL_EFFECTIVE_FROM as COUNT_NULL_EFFECTIVE_FROM,
----@COUNT_NULL_EFFECTIVE_TO as COUNT_NULL_EFFECTIVE_TO,
--@COUNT_NULL_CONNECTION_FROM_ID as COUNT_NULL_CONNECTION_FROM_ID,
--@COUNT_NULL_CONNECTION_TO_ID as COUNT_NULL_CONNECTION_TO_ID,
----@COUNT_NULL_CONNECTION_FROM_CATEGORY_ID as COUNT_NULL_CONNECTION_FROM_CATEGORY_ID,
----@COUNT_NULL_CONNECTION_TO_CATEGORY_ID as COUNT_NULL_CONNECTION_TO_CATEGORY_ID,
--@COUNT_NULL_CONNECTION_FROM_CATEGORY as COUNT_NULL_CONNECTION_FROM_CATEGORY,
--@COUNT_NULL_CONNECTION_TO_CATEGORY as COUNT_NULL_CONNECTION_TO_CATEGORY,
--@COUNT_NULL_CONGESTED_ZONE_ID as COUNT_NULL_CONGESTED_ZONE_ID,
----@COUNT_NULL_IS_ENERGY_IMPORTED as COUNT_NULL_IS_ENERGY_IMPORTED,
----@COUNT_NULL_IS_ASSIGNED as COUNT_NULL_IS_ASSIGNED,
--@COUNT_NULL_LINE_VOLTAGE as COUNT_NULL_LINE_VOLTAGE


DECLARE @logMessage VARCHAR(MAX),
@logMessage_effectiveDate VARCHAR(MAX),
@logMessage_CongestedZone VARCHAR(MAX),
@logMessage_LineVoltage VARCHAR(MAX);

DECLARE @CDP_LIST NVARCHAR(MAX)
DECLARE @COUNT_NULL_CDPs INT;
IF(@COUNT_NULL_CONNECTION_FROM_ID >0 
OR @COUNT_NULL_CONNECTION_TO_ID >0 )
BEGIN
	SET @CDP_LIST = NULL;
	SELECT 
		@CDP_LIST = ISNULL(@CDP_LIST + ', ', '') + c.RuCDPDetail_CdpId from RuCDPDetail C WHERE C.RuCDPDetail_ConnectedToID is NULL OR C.RuCDPDetail_ConnectedFromID is NULL;

	SELECT @COUNT_NULL_CDPs = COUNT(rc.RuCDPDetail_CdpId) FROM RuCDPDetail rc WHERE rc.RuCDPDetail_ConnectedToID is NULL OR rc.RuCDPDetail_ConnectedFromID is NULL;

	SET @logMessage = 'Missing Total - ' + CAST(@COUNT_NULL_CDPs AS NVARCHAR(MAX)) + ': CDPs without Connected-To And/ Or Connected-From mapping: '+ @CDP_LIST ;
	
END

IF(@COUNT_NULL_EFFECTIVE_FROM > 0)
BEGIN
	SET @CDP_LIST = NULL;
	SELECT 
		@CDP_LIST = ISNULL(@CDP_LIST + ', ', '') + c.RuCDPDetail_CdpId FROM RuCDPDetail C WHERE C.RuCDPDetail_EffectiveFrom is NULL;

	--SELECT @COUNT_NULL_CDPs = COUNT(rc.RuCDPDetail_CdpId) FROM RuCDPDetail rc WHERE rc.RuCDPDetail_ConnectedToID is NULL OR rc.RuCDPDetail_EffectiveFrom is NULL;

	SET @logMessage_effectiveDate = 'Missing Total - ' + CAST(@COUNT_NULL_EFFECTIVE_FROM AS NVARCHAR(MAX)) +': CDPs without Effective From Date: ' + @CDP_LIST;
	
END

IF(@COUNT_NULL_CONGESTED_ZONE_ID > 0)
BEGIN
	SET @CDP_LIST = NULL;
	SELECT 
		@CDP_LIST = ISNULL(@CDP_LIST + ', ', '') + c.RuCDPDetail_CdpId FROM RuCDPDetail C WHERE C.RuCDPDetail_CongestedZoneID is NULL;
	--SELECT @COUNT_NULL_CDPs = COUNT(rc.RuCDPDetail_CdpId) FROM RuCDPDetail rc WHERE rc.RuCDPDetail_ConnectedToID is NULL OR rc.RuCDPDetail_CongestedZoneID is NULL;

	SET @logMessage_CongestedZone ='Missing Total - ' +  CAST(@COUNT_NULL_CONGESTED_ZONE_ID AS NVARCHAR(MAX)) + ': CDP Zones not defined for each Generation-Unit: ' + @CDP_LIST;
	
END



SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage AS [LOG_MESSAGE], CASE WHEN @logMessage IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_effectiveDate AS [LOG_MESSAGE], CASE WHEN @logMessage_effectiveDate IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL] WHERE @logMessage_effectiveDate IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_CongestedZone AS [LOG_MESSAGE], CASE WHEN @logMessage_CongestedZone IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL] WHERE @logMessage_CongestedZone IS NOT NULL

 END TRY
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END
