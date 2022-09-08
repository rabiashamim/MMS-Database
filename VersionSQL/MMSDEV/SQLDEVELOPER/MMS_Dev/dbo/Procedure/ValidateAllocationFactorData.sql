/****** Object:  Procedure [dbo].[ValidateAllocationFactorData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 
-- [dbo].[ValidateAllocationFactorData]
CREATE PROCEDURE [dbo].[ValidateAllocationFactorData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
SELECT [LuAllocationFactors_Id]
      ,[MtPartyRegisteration_Id]
      ,[LuAllocationFactors_Factor]
      ,[LuAllocationFactors_StaticCapValue]
      ,[LuAllocationFactors_Entity]
      ,[LuAllocationFactors_EffectiveFrom]
      ,[LuAllocationFactors_EffectiveTo]
      ,[LuAllocationFactors_CreatedDate]
      ,[LuAllocationFactors_UpdatedDate]
      ,[LuAllocationFactors_CreatedBy]
      ,[LuallocationFactors_ModifiedBy]
  FROM [LuAllocationFactors]
*/
DECLARE @COUNT_AL INT=0;
DECLARE @COUNT_NULL_EFFECTIVE_FROM INT=0;
DECLARE @COUNT_NULL_FACTOR INT=0;
DECLARE @COUNT_BSUP INT=0;
DECLARE @COUNT_BSUP_DEFINED INT=0;
DECLARE @COUNT_BSUP_NOT_DEFINED INT=0;

select @COUNT_AL = COUNT(1),
@COUNT_BSUP_DEFINED =COUNT(DISTINCT C.MtPartyRegisteration_Id),
@COUNT_NULL_EFFECTIVE_FROM=SUM(CASE WHEN C.LuAllocationFactors_EffectiveFrom is null THEN 1 ELSE 0 END),
@COUNT_NULL_FACTOR=SUM(CASE WHEN ISNULL(C.LuAllocationFactors_Factor,0)=0 AND ISNULL(C.LuAllocationFactors_StaticCapValue,0)=0 THEN 1 ELSE 0 END)
        from LuAllocationFactors C WHERE (C.LuAllocationFactors_EffectiveTo IS NULL OR C.LuAllocationFactors_EffectiveTo>=GETDATE())
        AND C.MtPartyRegisteration_Id IN(
        select P.PartyRegisteration_Id from dbo.Bme_Parties2 P WHERE P.PartyCategory_Code='BSUP') ;

 select @COUNT_BSUP = COUNT(DISTINCT C.PartyRegisteration_Id)
	    from dbo.Bme_Parties2 C WHERE C.PartyCategory_Code='BSUP';

SET @COUNT_BSUP_NOT_DEFINED =@COUNT_BSUP - @COUNT_BSUP_DEFINED;

--SELECT @COUNT_AL as COUNT_AL,
--@COUNT_NULL_EFFECTIVE_FROM as COUNT_NULL_EFFECTIVE_FROM,
--@COUNT_NULL_FACTOR as COUNT_NULL_FACTOR,
--@COUNT_BSUP AS COUNT_BSUP,
--@COUNT_BSUP_DEFINED AS COUNT_BSUP_DEFINED,
--@COUNT_BSUP_NOT_DEFINED AS COUNT_BSUP_NOT_DEFINED;

DECLARE @logMessage_EffectiveFrom VARCHAR(MAX),
@logMessage_bsup_missing VARCHAR(MAX),
@logMessage_factor_null VARCHAR(MAX);


DECLARE @PARTIES_LIST NVARCHAR(MAX);
IF(@COUNT_NULL_EFFECTIVE_FROM > 0)
BEGIN
	SET @PARTIES_LIST = NULL;
	SELECT  @PARTIES_LIST = ISNULL(@PARTIES_LIST + ', ', '') + CAST(C.MtPartyRegisteration_Id AS NVARCHAR(MAX))
        from LuAllocationFactors C WHERE (C.LuAllocationFactors_EffectiveTo IS NULL OR C.LuAllocationFactors_EffectiveTo>=GETDATE())
        AND C.MtPartyRegisteration_Id IN(
        select P.PartyRegisteration_Id from dbo.Bme_Parties2 P WHERE P.PartyCategory_Code='BSUP')
		AND C.LuAllocationFactors_EffectiveFrom is null;


	SET @logMessage_EffectiveFrom = 'Missing Total - ' + CAST(@COUNT_NULL_EFFECTIVE_FROM AS NVARCHAR(MAX)) + ': Distribution Loss without Effective From date: ' + @PARTIES_LIST;
	
END

IF(@COUNT_BSUP_NOT_DEFINED > 0)
BEGIN
	
	SET @PARTIES_LIST=NULL;

		SELECT @PARTIES_LIST = ISNULL(@PARTIES_LIST + ', ', '') + CAST(bp.PartyRegisteration_Id AS NVARCHAR(MAX)) 
		FROM dbo.Bme_Parties2 bp 
		WHERE bp.PartyCategory_Code = 'BSUP'
			AND bp.PartyRegisteration_Id NOT IN (SELECT laf.MtPartyRegisteration_Id FROM LuAllocationFactors laf);

	SET @logMessage_bsup_missing = 'Missing Total - ' + CAST(@COUNT_BSUP_NOT_DEFINED AS NVARCHAR(MAX)) +  ': Allocation factor of SOLR is missing: ' + @PARTIES_LIST;
END


SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_EffectiveFrom AS [LOG_MESSAGE], CASE WHEN @logMessage_EffectiveFrom IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_EffectiveFrom IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_bsup_missing AS [LOG_MESSAGE], CASE WHEN @logMessage_bsup_missing IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_bsup_missing IS NOT NULL





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
