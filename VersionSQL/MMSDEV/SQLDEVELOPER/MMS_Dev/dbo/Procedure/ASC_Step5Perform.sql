/****** Object:  Procedure [dbo].[ASC_Step5Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure [dbo].[ASC_Step5Perform](			 
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


--DROP TABLE IF EXISTS #tempAC
--DROP TABLE IF EXISTS #TempBVMSum

/*
SELECT GUH.AscStatementData_StatementProcessId, GUH.AscStatementData_Generator_Id, Guh.AscStatementData_NtdcDateTime,
SUM
 (Case when IG.MtGenerationUnit_Id is null then GUH.AscStatementData_SO_AC_ASC end) as NotEntitle_AC_ASC
     ,Sum(Case when IG.MtGenerationUnit_Id is not null then GUH.AscStatementData_SO_AC_ASC end) as Entitle_AC_ASC
INTO #tempAC
 from AscStatementDataGuHourly GUH 

LEFT JOIN MtAscIG IG ON  GUH.AscStatementData_SOUnitId=IG.MtGenerationUnit_Id 
--and GUH.AscStatementData_NtdcDateTime=RG.MTAscIG_NtdcDateTime
AND  DATEADD(HOUR,CAST(IG.MtAscIG_Hour AS INT)+1,CAST(IG.MtAscIG_Date AS datetime))=GUH.AscStatementData_NtdcDateTime
and IG.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId,5)-- 52
WHERE GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month
and GUH.AscStatementData_StatementProcessId=@StatementProcessId
GROUP By GUH.AscStatementData_StatementProcessId,GUH.AscStatementData_Generator_Id, Guh.AscStatementData_NtdcDateTime





Select GUP.AscStatementData_StatementProcessId, CDPH.BmeStatementData_NtdcDateTime, GUP.AscStatementData_SOUnitId,
	SUM( ISNULL(CASE WHEN GUP.AscStatementData_FromPartyCategory_Code in ('GEN','CGEN','EGEN') THEN CDPH.BmeStatementData_IncEnergyExport 
	      WHEN GUP.AscStatementData_ToPartyCategory_Code in ('GEN','CGEN','EGEN') THEN CDPH.BmeStatementData_IncEnergyImport END,0))as BVMsum
	
into #TempBVMSum
from
	[dbo].[AscStatementDataCdpGuParty] GUP
INNER JOIN BmeStatementDataCdpHourly CDPH ON  
GUP.AscStatementData_CdpId=CDPH.BmeStatementData_CdpId
and GUP.AscStatementData_StatementProcessId=@StatementProcessId
WHERE CDPH.BmeStatementData_Year=@Year and CDPH.BmeStatementData_Month=@Month
and CDPH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
and GUP.AscStatementData_StatementProcessId=@StatementProcessId
GROUP BY GUP.AscStatementData_StatementProcessId,GUP.AscStatementData_SOUnitId , CDPH.BmeStatementData_NtdcDateTime



UPDATE AscStatementDataGuHourly SET
AscStatementData_IG_EAG= ((ISNULL(TBS.BVMsum,0)-ISNULL(TAC.NotEntitle_AC_ASC,0))/NULLIF(TAC.Entitle_AC_ASC,0))*ISNULL(GUH.AscStatementData_SO_AC_ASC,0)
from AscStatementDataGuHourly GUH 
INNER JOIN #tempAC TAC  ON TAC.AscStatementData_Generator_Id = GUH.AscStatementData_Generator_Id
		and TAC.AscStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime 
		AND TAC.AscStatementData_StatementProcessId=GUH.AscStatementData_StatementProcessId
INNER JOIN #TempBVMSum TBS ON TBS.BmeStatementData_NtdcDateTime =  GUH.AscStatementData_NtdcDateTime 
AND TBS.AscStatementData_StatementProcessId=GUH.AscStatementData_StatementProcessId
AND GUH.AscStatementData_SOUnitId=TBS.AscStatementData_SOUnitId
where
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId and GUH.AscStatementData_IsIG=1
*/


UPDATE AscStatementDataGuHourly SET
AscStatementData_IG_EAG=BGUH.BmeStatementData_UnitWiseGeneration
from AscStatementDataGuHourly GUH 
INNER JOIN [BmeStatementDataGenUnitHourly] BGUH 
         ON BGUH.BmeStatementData_MtGeneratorUnit_Id = GUH.AscStatementData_GenerationUnit_Id
		AND BGUH.BmeStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime 
	    AND BGUH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
where
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId and GUH.AscStatementData_IsIG=1



/*
Step5.2   Calculate IG_EPG 
IG_EPG = SO_IG_EPG

Step5.3   Calculate UPC
UPC = IG_EAG – IG_EPG 

*/

UPDATE AscStatementDataGuHourly SET

AscStatementData_IG_EPG =AscStatementData_SO_IG_EPG
,AscStatementData_IG_UPC = ISNULL(AscStatementData_IG_EAG,0)-ISNULL(AscStatementData_SO_IG_EPG,0)
where
AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId and AscStatementData_IsIG=1

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
