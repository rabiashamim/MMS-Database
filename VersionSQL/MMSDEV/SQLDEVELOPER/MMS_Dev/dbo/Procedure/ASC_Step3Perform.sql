/****** Object:  Procedure [dbo].[ASC_Step3Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure  [dbo].[ASC_Step3Perform](			 
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

 drop table if EXISTS #TempEAG

/*
step 3.1 Calculate Must Run EAG
*/


Select GUP.AscStatementData_CdpId,GUP.AscStatementData_SOUnitId, CDPH.BmeStatementData_NtdcDateTime,
 CDPH.BmeStatementData_IncEnergyExport,CDPH.BmeStatementData_IncEnergyImport,
	 ISNULL(CASE WHEN GUP.AscStatementData_FromPartyCategory_Code in ('GEN','CGEN','EGEN') THEN CDPH.BmeStatementData_IncEnergyExport 
	      WHEN GUP.AscStatementData_ToPartyCategory_Code in ('GEN','CGEN','EGEN') THEN CDPH.BmeStatementData_IncEnergyImport END,0)as EAG
	
into #TempEAG
from
	[dbo].[AscStatementDataCdpGuParty] GUP
INNER JOIN BmeStatementDataCdpHourly CDPH ON  GUP.AscStatementData_CdpId=CDPH.BmeStatementData_CdpId
WHERE  GUP.AscStatementData_StatementProcessId=@StatementProcessId and CDPH.BmeStatementData_Year=@Year and CDPH.BmeStatementData_Month=@Month and CDPH.BmeStatementData_StatementProcessId=@BmeStatementProcessId;

UPDATE AscStatementDataGuHourly SET
AscStatementData_MR_EAG=TE.EAG
from AscStatementDataGuHourly GUH INNER JOIN #TempEAG TE
on GUH.AscStatementData_SOUnitId=TE.AscStatementData_SOUnitId and GUH.AscStatementData_NtdcDateTime=TE.BmeStatementData_NtdcDateTime
where
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId
AND GUH.AscStatementData_Generator_Id  
IN (
SELECT GUP.AscStatementData_Generator_Id FROM [dbo].[AscStatementDataCdpGuParty] GUP where AscStatementData_StatementProcessId = @StatementProcessId
GROUP by GUP.AscStatementData_Generator_Id
HAVING count(GUP.AscStatementData_SOUnitId)=1
)


UPDATE AscStatementDataGuHourly SET
AscStatementData_MR_EAG=TE.EAG - 
--select GUH.AscStatementData_SOUnitId ,TE.EAG,
ISNULL(

(SELECT SUM(ISNULL(GH.AscStatementData_SO_AC_ASC,0)) FROM AscStatementDataGuHourly GH
WHERE GH.AscStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime 
and GH.AscStatementData_StatementProcessId = @StatementProcessId
and GH.AscStatementData_SOUnitId IN(
select DISTINCT AscStatementData_SOUnitId from AscStatementDataCdpGuParty 
WHERE AscStatementData_StatementProcessId = @StatementProcessId and 
AscStatementData_RuCDPDetail_Id 
    in(
    select  AscStatementData_RuCDPDetail_Id from AscStatementDataCdpGuParty 
    where AscStatementData_StatementProcessId = @StatementProcessId and AscStatementData_SOUnitId=GUH.AscStatementData_SOUnitId 
    )
) AND AscStatementData_SOUnitId<>GUH.AscStatementData_SOUnitId
),0)
from AscStatementDataGuHourly GUH 
INNER JOIN 
(select T.AscStatementData_SOUnitId,T.BmeStatementData_NtdcDateTime, SUM(T.EAG) AS EAG FROM #TempEAG T
GROUP BY T.AscStatementData_SOUnitId, T.BmeStatementData_NtdcDateTime
) TE
on GUH.AscStatementData_SOUnitId=TE.AscStatementData_SOUnitId and GUH.AscStatementData_NtdcDateTime=TE.BmeStatementData_NtdcDateTime
where
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId
and AscStatementData_IsGenMR=1

AND GUH.AscStatementData_Generator_Id  IN (
SELECT GUP.AscStatementData_Generator_Id FROM [dbo].[AscStatementDataCdpGuParty] GUP WHERE AscStatementData_StatementProcessId = @StatementProcessId
GROUP by GUP.AscStatementData_Generator_Id
HAVING count(GUP.AscStatementData_SOUnitId)>1
);

/*
step 3.2 Calculate Must Run EPG
"MR_EPG = SO_MR_EP
"
*/

UPDATE AscStatementDataGuHourly SET

AscStatementData_MR_EPG=AscStatementData_SO_MR_EP
from AscStatementDataGuHourly GUH 

where 
GUH.AscStatementData_Year=@Year and GUH.AscStatementData_Month=@Month and GUH.AscStatementData_StatementProcessId=@StatementProcessId
 and GUH.AscStatementData_IsGenMR=1;


/*
Step 3.3 Calculate Must Run MRC
"Variable Price of generator unit to be compensated -  Marginal Price of that hour
MRC =  (MR_EAG - MR_EPG) * (SO_MR_VC - SO_MP)
"

*/



UPDATE AscStatementDataGuHourly SET
AscStatementData_MRC= ISNULL(AscStatementData_MR_EAG - ISNULL(AscStatementData_MR_EPG,0),0) * ISNULL((AscStatementData_SO_MR_VC - AscStatementData_SO_MP),0),
AscStatementData_MR_UPC=ISNULL(AscStatementData_MR_EAG - ISNULL(AscStatementData_MR_EPG,0),0)
WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId and AscStatementData_IsGenMR=1;



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
