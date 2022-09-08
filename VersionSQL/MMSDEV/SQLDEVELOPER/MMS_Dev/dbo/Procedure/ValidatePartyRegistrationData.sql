/****** Object:  Procedure [dbo].[ValidatePartyRegistrationData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 

-- exec [dbo].[ValidatePartyRegistrationData]
CREATE PROCEDURE [dbo].[ValidatePartyRegistrationData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
SELECT [MtPartyRegisteration_Id]
      ,[MtPartyRegisteration_Name]
      ,[MtPartyRegisteration_Remarks]
      ,[MtPartyRegisteration_IsPowerPool]
      ,[SrPartyType_Code]
      ,[MtPartyRegisteration_CreatedBy]
      ,[MtPartyRegisteration_CreatedOn]
      ,[MtPartyRegisteration_ModifiedBy]
      ,[MtPartyRegisteration_ModifiedOn]
      ,[LuStatus_Code_Approval]
      ,[LuStatus_Code_Applicant]
      ,[MtPartyRegisteration_MPId]
      ,[isDeleted]
      ,[MtPartyRegisteration_IsKE]
  FROM [MtPartyRegisteration]
*/
DECLARE @COUNT_PARTY_REGISTERATION INT=0;
DECLARE @COUNT_POWER_POOL INT=0;
DECLARE @COUNT_KE INT=0;
DECLARE @COUNT_POWER_POOL_NOT_DEFINED INT=0;
DECLARE @COUNT_KE_NOT_DEFINED INT=0;
DECLARE @COUNT_EP INT=0;
DECLARE @COUNT_EP_RELATION_WITH_MP_NOT_DEFINED INT=0;
DECLARE @COUNT_DSP INT=0;
DECLARE @COUNT_DSP_RELATION_WITH_SOLR_DEFINED INT=0;
DECLARE @COUNT_DSP_RELATION_WITH_SOLR_NOT_DEFINED INT=0;

select @COUNT_PARTY_REGISTERATION = COUNT(1),
@COUNT_POWER_POOL=SUM(CASE WHEN C.MtPartyRegisteration_IsPowerPool=1 THEN 1 ELSE 0 END),
@COUNT_KE=SUM(CASE WHEN C.MtPartyRegisteration_IsKE=1 THEN 1 ELSE 0 END),
@COUNT_EP=SUM(CASE WHEN C.SrPartyType_Code='EP' THEN 1 ELSE 0 END),
@COUNT_EP_RELATION_WITH_MP_NOT_DEFINED=SUM(CASE WHEN C.SrPartyType_Code='EP' AND C.MtPartyRegisteration_MPId IS NULL THEN 1 ELSE 0 END)
        from MtPartyRegisteration C WHERE (C.isDeleted = 0) and C.LuStatus_Code_Applicant='AACT';


 select @COUNT_DSP = COUNT(DISTINCT C.PartyRegisteration_Id),
 @COUNT_DSP_RELATION_WITH_SOLR_NOT_DEFINED=SUM(CASE WHEN C.MPId IS NULL THEN 1 ELSE 0 END)
	    from dbo.Bme_Parties2 C WHERE C.PartyType_Code='SP' AND C.PartyCategory_Code='DSP';

SET @COUNT_POWER_POOL_NOT_DEFINED= CASE WHEN @COUNT_POWER_POOL=0 THEN 1 ELSE 0 END;
SET @COUNT_KE_NOT_DEFINED = CASE WHEN @COUNT_KE=0 THEN 1 ELSE 0 END;
-----------------------------------------------------
--SELECT @COUNT_PARTY_REGISTERATION as COUNT_PARTY_REGISTERATION,
--@COUNT_POWER_POOL_NOT_DEFINED as COUNT_POWER_POOL_NOT_DEFINED,
--@COUNT_KE_NOT_DEFINED as COUNT_KE_NOT_DEFINED,
--@COUNT_EP_RELATION_WITH_MP_NOT_DEFINED AS COUNT_EP_RELATION_WITH_MP_NOT_DEFINED,
--@COUNT_DSP_RELATION_WITH_SOLR_NOT_DEFINED AS COUNT_DSP_RELATION_WITH_SOLR_NOT_DEFINED;


DECLARE @logMessage_powerPool_not_def VARCHAR(MAX),
@logMessage_KE_Not_def VARCHAR(MAX),
@logMessage_EP_With_MP_not_def VARCHAR(MAX),
@logMessage_DSP_With_SOLR_not_def VARCHAR(MAX);

DECLARE @REG_LIST VARCHAR(MAX);

IF(@COUNT_POWER_POOL_NOT_DEFINED > 0)
BEGIN
	SET @logMessage_powerPool_not_def = 'Power Pool MP is not Defined';
END

IF(@COUNT_KE_NOT_DEFINED > 0)
BEGIN
	SET @logMessage_KE_Not_def = 'KE MP is not Defined';
END

IF(@COUNT_EP_RELATION_WITH_MP_NOT_DEFINED > 0)
BEGIN
SET @REG_LIST=NULL;
SELECT 
	@REG_LIST = ISNULL(@REG_LIST + ', ', '') + CAST(C.MtPartyRegisteration_Id AS NVARCHAR(MAX))	    
        from MtPartyRegisteration C WHERE C.SrPartyType_Code='EP' AND C.MtPartyRegisteration_MPId IS NULL and (C.isDeleted = 0) and C.LuStatus_Code_Applicant='AACT';


	SET @logMessage_EP_With_MP_not_def ='Missing Total - ' +  CAST(@COUNT_EP_RELATION_WITH_MP_NOT_DEFINED AS NVARCHAR(MAX)) + ': Enrolled person relation with Trader/CS: '+ @REG_LIST ;
END

IF(@COUNT_DSP_RELATION_WITH_SOLR_NOT_DEFINED > 0)
BEGIN

SET @REG_LIST=NULL;
SELECT 
	@REG_LIST = ISNULL(@REG_LIST + ', ', '') + CAST(C.PartyRegisteration_Id AS NVARCHAR(MAX))	            
	    from dbo.Bme_Parties2 C WHERE C.MPId IS NULL AND C.PartyType_Code='SP' AND C.PartyCategory_Code='DSP';

	SET @logMessage_DSP_With_SOLR_not_def ='Missing Total - ' +  CAST(@COUNT_DSP_RELATION_WITH_SOLR_NOT_DEFINED AS NVARCHAR(MAX)) + ': DSP relation with SOLR: '+ @REG_LIST ;
END

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_powerPool_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_powerPool_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_powerPool_not_def IS NOT NULL

UNION

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_KE_Not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_KE_Not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_KE_Not_def IS NOT NULL

UNION

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_EP_With_MP_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_EP_With_MP_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_EP_With_MP_not_def IS NOT NULL

UNION

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_DSP_With_SOLR_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_DSP_With_SOLR_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_DSP_With_SOLR_not_def IS NOT NULL


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
