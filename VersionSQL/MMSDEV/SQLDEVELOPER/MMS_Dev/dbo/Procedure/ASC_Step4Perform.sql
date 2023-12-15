/****** Object:  Procedure [dbo].[ASC_Step4Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure dbo.ASC_Step4Perform(			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) 
			)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY    
   IF EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataGuHourly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
   BEGIN
 DECLARE @BmeStatementProcessId decimal(18,0) = null;
SELECT top 1 @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@StatementProcessId);
-----------------------
/*
select GUH.AscStatementData_StatementProcessId,GUH.AscStatementData_Generator_Id, Guh.AscStatementData_NtdcDateTime,
SUM(Case when RG.MtGenerationUnit_Id is null then GUH.AscStatementData_SO_AC_ASC end) as NotEntitle_AC_ASC
,SUM(Case when RG.MtGenerationUnit_Id is not null then GUH.AscStatementData_SO_AC_ASC end) as Entitle_AC_ASC
INTO #tempAC
 from AscStatementDataGuHourly GUH 

LEFT JOIN MtAscRG RG ON  GUH.AscStatementData_SOUnitId=RG.MtGenerationUnit_Id 
AND  DATEADD(HOUR,CAST(RG.MtAscRG_Hour AS INT)+1,CAST(RG.MtAscRG_Date AS datetime))=GUH.AscStatementData_NtdcDateTime
and RG.MtSOFileMaster_Id= dbo.GetMtSoFileMasterId(@StatementProcessId,6)--56
WHERE GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month
and GUH.AscStatementData_StatementProcessId=@StatementProcessId
GROUP By GUH.AscStatementData_StatementProcessId,GUH.AscStatementData_Generator_Id, GUH.AscStatementData_NtdcDateTime;

Select   CDPH.BmeStatementData_NtdcDateTime, GUP.AscStatementData_SOUnitId,
	SUM( ISNULL(CASE WHEN GUP.AscStatementData_FromPartyCategory_Code in ('GEN','CGEN','EGEN') THEN CDPH.BmeStatementData_IncEnergyExport 
	      WHEN GUP.AscStatementData_ToPartyCategory_Code in ('GEN','CGEN','EGEN') THEN CDPH.BmeStatementData_IncEnergyImport END,0))as BVMsum
	
into #TempBVMSum
from
	[dbo].[AscStatementDataCdpGuParty] GUP
INNER JOIN BmeStatementDataCdpHourly CDPH ON  
GUP.AscStatementData_CdpId=CDPH.BmeStatementData_CdpId
and GUP.AscStatementData_StatementProcessId=@StatementProcessId
WHERE CDPH.BmeStatementData_Year=@Year and CDPH.BmeStatementData_Month=@Month and CDPH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
AND GUP.AscStatementData_StatementProcessId=@StatementProcessId
GROUP BY GUP.AscStatementData_SOUnitId , CDPH.BmeStatementData_NtdcDateTime



--SELECT GUH.AscStatementData_SOUnitId, TBS.BVMsum,TAC.NotEntitle_AC_ASC,TAC.Entitle_AC_ASC,GUH.AscStatementData_SO_AC_ASC
-- --((ISNULL(TBS.BVMsum,0)-ISNULL(TAC.NotEntitle_AC_ASC,0))/NULLIF(TAC.Entitle_AC_ASC,0))*ISNULL(GUH.AscStatementData_SO_AC_ASC,0)
--from AscStatementDataGuHourly GUH 
--INNER JOIN #tempAC TAC  ON TAC.AscStatementData_Generator_Id = GUH.AscStatementData_Generator_Id
--		and TAC.AscStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime 
--INNER JOIN #TempBVMSum TBS ON TBS.BmeStatementData_NtdcDateTime =  GUH.AscStatementData_NtdcDateTime 
--AND GUH.AscStatementData_SOUnitId=TBS.AscStatementData_SOUnitId
--where
--GUH.AscStatementData_Year=2021 and GUH.AscStatementData_Month=11
--AND GUH.AscStatementData_SOUnitId=11002


UPDATE AscStatementDataGuHourly SET
AscStatementData_RG_EAG= ((ISNULL(TBS.BVMsum,0)-ISNULL(TAC.NotEntitle_AC_ASC,0))/NULLIF(TAC.Entitle_AC_ASC,0))*ISNULL(GUH.AscStatementData_SO_AC_ASC,0)
from AscStatementDataGuHourly GUH 
INNER JOIN #tempAC TAC  ON TAC.AscStatementData_Generator_Id = GUH.AscStatementData_Generator_Id
		and TAC.AscStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime 
INNER JOIN #TempBVMSum TBS ON TBS.BmeStatementData_NtdcDateTime =  GUH.AscStatementData_NtdcDateTime 
AND GUH.AscStatementData_SOUnitId=TBS.AscStatementData_SOUnitId
where
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId and GUH.AscStatementData_IsRG=1;

*/





UPDATE AscStatementDataGuHourly SET
AscStatementData_RG_EAG=BGUH.BmeStatementData_UnitWiseGeneration
from AscStatementDataGuHourly GUH 
INNER JOIN [BmeStatementDataGenUnitHourly_SettlementProcess]  BGUH 
         ON BGUH.BmeStatementData_MtGeneratorUnit_Id = GUH.AscStatementData_GenerationUnit_Id
		AND BGUH.BmeStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime 
	    AND BGUH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
where
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId 
and GUH.AscStatementData_IsRG=1


/*
Step4.2   Calculate AC_MOD 
Step4.3   Calculate LOCC
*/

UPDATE AscStatementDataGuHourly SET

AscStatementData_AC_MOD = CASE WHEN AscStatementData_SO_RG_UT='ARE' THEN AscStatementData_SO_AC_ASC
							   else  0.95*AscStatementData_SO_AC_ASC END

,AscStatementData_RG_LOCC= (CASE WHEN ISNULL(AscStatementData_IsRG,0)=0 THEN null
								WHEN  AscStatementData_SO_RG_UT='ARE' THEN AscStatementData_SO_AC_ASC
							   else  0.95*AscStatementData_SO_AC_ASC END) - ISNULL(AscStatementData_RG_EAG,0)
WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId

SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END
 ELSE
 BEGIN
 SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END 
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
