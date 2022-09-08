/****** Object:  Procedure [dbo].[ValidateDistLossData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 
-- exec [dbo].[ValidateDistLossData]
CREATE PROCEDURE [dbo].[ValidateDistLossData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
SELECT [Lu_DistLosses_Id]
      ,[Lu_DistLosses_MP_Id]
      ,[Lu_DistLosses_MP_Name]
      ,[Lu_DistLosses_LineVoltage]
      ,[Lu_DistLosses_Factor]
      ,[Lu_DistLosses_EffectiveFrom]
      ,[Lu_DistLosses_EffectiveTo]
      ,[MtPartyRegisteration_Id]
      ,[Lu_DistLosses_CreatedDate]
      ,[Lu_DistLosses_UpdatedDate]
  FROM [dbo].[Lu_DistLosses]
*/
DECLARE @COUNT_DL INT=0;
DECLARE @COUNT_NULL_EFFECTIVE_FROM INT=0;
DECLARE @COUNT_NULL_FACTOR INT=0;
DECLARE @COUNT_NULL_LINE_VOLTAGE INT=0;
DECLARE @COUNT_DSP INT=0;
DECLARE @COUNT_DSP_DEFINED INT=0;
DECLARE @COUNT_DSP_NOT_DEFINED INT=0;

select @COUNT_DL = COUNT(1),
@COUNT_DSP_DEFINED =COUNT(DISTINCT C.MtPartyRegisteration_Id),
@COUNT_NULL_EFFECTIVE_FROM=SUM(CASE WHEN C.Lu_DistLosses_EffectiveFrom is null THEN 1 ELSE 0 END),
@COUNT_NULL_FACTOR=SUM(CASE WHEN C.Lu_DistLosses_Factor is null THEN 1 ELSE 0 END),
@COUNT_NULL_LINE_VOLTAGE=SUM(CASE WHEN C.Lu_DistLosses_LineVoltage is null THEN 1 ELSE 0 END)
        from Lu_DistLosses C WHERE (C.Lu_DistLosses_EffectiveTo IS NULL OR C.Lu_DistLosses_EffectiveTo>=GETDATE())
        AND C.MtPartyRegisteration_Id IN(
        select P.PartyRegisteration_Id from dbo.Bme_Parties2 P WHERE P.PartyType_Code='SP' AND P.PartyCategory_Code='DSP') ;

--------------------------
 select @COUNT_DSP = COUNT(1)
	    from dbo.Bme_Parties2 C WHERE C.PartyType_Code='SP' AND C.PartyCategory_Code='DSP';

-------------------------------------
 select @COUNT_DSP = COUNT(1)
	    from dbo.Bme_Parties2 C WHERE C.PartyType_Code='SP' AND C.PartyCategory_Code='DSP';
select distinct * 
into #TempDSP_Not_Def
from(
select cdp.RuCDPDetail_ConnectedFromID ID, CDP.RuCDPDetail_LineVoltage,DL.Lu_DistLosses_Factor from RuCDPDetail CDP  
LEFT JOIN Lu_DistLosses DL
 ON DL.MtPartyRegisteration_Id=CDP.RuCDPDetail_ConnectedFromID AND CDP.RuCDPDetail_LineVoltage=DL.Lu_DistLosses_LineVoltage
 WHERE (CDP.RuCDPDetail_EffectiveTo IS NULL OR CDP.RuCDPDetail_EffectiveTo>=GETDATE()) and (DL.Lu_DistLosses_EffectiveTo IS NULL OR DL.Lu_DistLosses_EffectiveTo>=GETDATE()) and CDP.RuCDPDetail_FromCustomerCategory='DSP' and CDP.RuCDPDetail_LineVoltage<=132
 UNION
select cdp.RuCDPDetail_ConnectedToID ID, CDP.RuCDPDetail_LineVoltage,DL.Lu_DistLosses_Factor from RuCDPDetail CDP  
LEFT JOIN Lu_DistLosses DL
 ON DL.MtPartyRegisteration_Id=CDP.RuCDPDetail_ConnectedToID AND CDP.RuCDPDetail_LineVoltage=DL.Lu_DistLosses_LineVoltage
 WHERE (CDP.RuCDPDetail_EffectiveTo IS NULL OR CDP.RuCDPDetail_EffectiveTo>=GETDATE()) and (DL.Lu_DistLosses_EffectiveTo IS NULL OR DL.Lu_DistLosses_EffectiveTo>=GETDATE()) and CDP.RuCDPDetail_ToCustomerCategory='DSP' and CDP.RuCDPDetail_LineVoltage<=132
) as T
where t.Lu_DistLosses_Factor is null;

set @COUNT_DSP_NOT_DEFINED=(select count(*) from #TempDSP_Not_Def);
-------------------------------------------
--SELECT @COUNT_DL as COUNT_DL,
--@COUNT_NULL_EFFECTIVE_FROM as COUNT_NULL_EFFECTIVE_FROM,
--@COUNT_NULL_FACTOR as COUNT_NULL_FACTOR,
--@COUNT_NULL_LINE_VOLTAGE as COUNT_NULL_LINE_VOLTAGE,
--@COUNT_DSP AS COUNT_DSP,
--@COUNT_DSP_DEFINED AS COUNT_DSP_DEFINED,
--@COUNT_DSP_NOT_DEFINED AS COUNT_DSP_NOT_DEFINED;


DECLARE @logMessage_dsp_not_def VARCHAR(MAX),
@logMessage_null_LineVoltage VARCHAR(MAX),
@logMessage_null_effectiveFrom VARCHAR(MAX);

DECLARE @REG_LIST VARCHAR(MAX);

IF(@COUNT_DSP_NOT_DEFINED > 0)
BEGIN
SET @REG_LIST=null;
 SELECT 
	@REG_LIST = ISNULL(@REG_LIST + ', ', '') + CAST(C.ID AS NVARCHAR(MAX))
	    from #TempDSP_Not_Def C
	SET @logMessage_dsp_not_def = 'Missing Total - ' + CAST(@COUNT_DSP_NOT_DEFINED AS NVARCHAR(MAX)) + ': Distribution Loss factor for any DSP is not defined: '+ @REG_LIST ;
END

IF(@COUNT_NULL_EFFECTIVE_FROM > 0)
BEGIN
SET @REG_LIST=null;
 SELECT 
	@REG_LIST = ISNULL(@REG_LIST + ', ', '') + CAST(C.MtPartyRegisteration_Id AS NVARCHAR(MAX))
        from Lu_DistLosses C WHERE C.Lu_DistLosses_EffectiveFrom is null and (C.Lu_DistLosses_EffectiveTo IS NULL OR C.Lu_DistLosses_EffectiveTo>=GETDATE())
        AND C.MtPartyRegisteration_Id IN(
        select P.PartyRegisteration_Id from dbo.Bme_Parties2 P WHERE P.PartyType_Code='SP' AND P.PartyCategory_Code='DSP') ;

	SET @logMessage_null_effectiveFrom = 'Missing Total - ' + CAST(@COUNT_DSP_NOT_DEFINED AS NVARCHAR(MAX)) + ': Distribution Loss without Effective From date: '+ @REG_LIST ;
END

IF(@COUNT_NULL_LINE_VOLTAGE > 0)
BEGIN
SET @REG_LIST=null;
 SELECT 
	@REG_LIST = ISNULL(@REG_LIST + ', ', '') + CAST(C.MtPartyRegisteration_Id AS NVARCHAR(MAX))
        from Lu_DistLosses C WHERE C.Lu_DistLosses_LineVoltage is null and (C.Lu_DistLosses_EffectiveTo IS NULL OR C.Lu_DistLosses_EffectiveTo>=GETDATE())
        AND C.MtPartyRegisteration_Id IN(
        select P.PartyRegisteration_Id from dbo.Bme_Parties2 P WHERE P.PartyType_Code='SP' AND P.PartyCategory_Code='DSP') ;

	SET @logMessage_null_LineVoltage = 'Missing Total - ' + CAST(@COUNT_NULL_LINE_VOLTAGE AS NVARCHAR(MAX)) + ': Distribution Loss factor for DSP’s Line Voltage is not defined: '+ @REG_LIST ;
END

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_dsp_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_dsp_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_dsp_not_def IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_null_effectiveFrom AS [LOG_MESSAGE], CASE WHEN @logMessage_null_effectiveFrom IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL] WHERE @logMessage_null_effectiveFrom IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_null_LineVoltage AS [LOG_MESSAGE], CASE WHEN @logMessage_null_LineVoltage IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL] WHERE @logMessage_null_LineVoltage IS NOT NULL


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
