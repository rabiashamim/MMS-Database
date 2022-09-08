/****** Object:  Procedure [dbo].[ASC_Step11Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure [dbo].[ASC_Step11Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
			)
AS
BEGIN
 BEGIN TRY
IF NOT EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataZoneMonthly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
    BEGIN

INSERT INTO [dbo].[AscStatementDataZoneMonthly]	
    (        
        [AscStatementData_StatementProcessId]
      ,[AscStatementData_Year]
      ,[AscStatementData_Month]      
	  ,AscStatementData_CongestedZoneID
      ,AscStatementData_CongestedZone
      
    )
SELECT distinct
@StatementProcessId
,@Year as Year,
@Month as Month                 
	  ,GU.RuCDPDetail_CongestedZoneID
      ,GU.MtCongestedZone_Name
      from ASC_GuParties GU;
--WHERE GU.[MtGenerationUnit_SOUnitId] in  (2002,10001,2001,11001,11002,9001,6001,6002,3001,3002,3003,3004);


select GUM.AscStatementData_CongestedZoneID,GUM.AscStatementData_Year, GUM.AscStatementData_Month,
       SUM([AscStatementData_SO_MP]) as [AscStatementData_SO_MP]
      ,SUM([AscStatementData_SO_AC]			) as[AscStatementData_SO_AC]
      ,SUM([AscStatementData_SO_AC_ASC]	   ) as [AscStatementData_SO_AC_ASC]
      ,SUM([AscStatementData_SO_MR_EP]	   ) as [AscStatementData_SO_MR_EP]
      ,SUM([AscStatementData_SO_MR_VC]	   ) as [AscStatementData_SO_MR_VC]
      
      ,SUM([AscStatementData_SO_RG_VC]	   ) as [AscStatementData_SO_RG_VC]
      ,SUM([AscStatementData_SO_RG_EG_ARE] ) as [AscStatementData_SO_RG_EG_ARE]
      ,SUM([AscStatementData_SO_IG_VC]	   ) as [AscStatementData_SO_IG_VC]
      ,SUM([AscStatementData_SO_IG_EPG]	   ) as [AscStatementData_SO_IG_EPG]
      ,SUM([AscStatementData_MR_EAG]	   ) as [AscStatementData_MR_EAG]
      ,SUM([AscStatementData_MR_EPG]	   ) as [AscStatementData_MR_EPG]
      ,SUM([AscStatementData_RG_EAG]	   ) as [AscStatementData_RG_EAG]
      ,SUM([AscStatementData_AC_MOD]	   ) as [AscStatementData_AC_MOD]
      ,SUM([AscStatementData_RG_LOCC]	   ) as [AscStatementData_RG_LOCC]
      ,SUM([AscStatementData_IG_EAG]	   ) as [AscStatementData_IG_EAG]
      ,SUM([AscStatementData_IG_EPG]	   ) as [AscStatementData_IG_EPG]
      ,SUM([AscStatementData_IG_UPC]	   ) as [AscStatementData_IG_UPC]
	  ,SUM([AscStatementData_RG_AC]	   ) as [AscStatementData_RG_AC]
	  ,SUM([AscStatementData_IG_AC]	   ) as [AscStatementData_IG_AC]
      ,SUM([AscStatementData_AC_Total]	   ) as [AscStatementData_AC_Total]
	  ,SUM([AscStatementData_SC_BSC]	   ) as [AscStatementData_SC_BSC]
	  ,SUM([AscStatementData_MAC]	   ) as [AscStatementData_MAC]
	  ,SUM([AscStatementData_MRC]	   ) as [AscStatementData_MRC]
	  ,SUM([AscStatementData_GS_SC]	   ) as [AscStatementData_GS_SC]
	  ,SUM([AscStatementData_GBS_BSC]	   ) as [AscStatementData_GBS_BSC]
	 ,SUM([AscStatementData_TAC]	   ) as [AscStatementData_TAC]
 
INTO #TempGUH
from AscStatementDataGenMonthly GUM
where GUM.AscStatementData_Year=@Year and GUM.AscStatementData_Month=@Month and GUM.AscStatementData_StatementProcessId=@StatementProcessId
GROUP BY GUM.AscStatementData_CongestedZoneID,GUM.AscStatementData_Year, GUM.AscStatementData_Month;


--------------
UPDATE AscStatementDataZoneMonthly
SET 
[AscStatementData_SO_AC]         =GH.[AscStatementData_SO_AC]
,[AscStatementData_SO_AC_ASC]	 =GH.[AscStatementData_SO_AC_ASC]
,[AscStatementData_SO_MR_EP]		 =GH.[AscStatementData_SO_MR_EP]
,[AscStatementData_SO_MR_VC]		 =GH.[AscStatementData_SO_MR_VC]

,[AscStatementData_SO_RG_VC]		 =GH.[AscStatementData_SO_RG_VC]
,[AscStatementData_SO_RG_EG_ARE]	 =GH.[AscStatementData_SO_RG_EG_ARE]
,[AscStatementData_SO_IG_VC]		 =GH.[AscStatementData_SO_IG_VC]
,[AscStatementData_SO_IG_EPG]	 =GH.[AscStatementData_SO_IG_EPG]
,[AscStatementData_MR_EAG]		 =GH.[AscStatementData_MR_EAG]
,[AscStatementData_MR_EPG]		 =GH.[AscStatementData_MR_EPG]

,[AscStatementData_RG_EAG]		 =GH.[AscStatementData_RG_EAG]
,[AscStatementData_AC_MOD]		 =GH.[AscStatementData_AC_MOD]
,[AscStatementData_RG_LOCC]		 =GH.[AscStatementData_RG_LOCC]
,[AscStatementData_IG_EAG]		 =GH.[AscStatementData_IG_EAG]
,[AscStatementData_IG_EPG]		 =GH.[AscStatementData_IG_EPG]
,[AscStatementData_IG_UPC]		 =GH.[AscStatementData_IG_UPC]
,[AscStatementData_RG_AC]		 =GH.[AscStatementData_RG_AC]
,[AscStatementData_IG_AC]		 =GH.[AscStatementData_IG_AC]
,[AscStatementData_AC_Total]		 =GH.[AscStatementData_AC_Total]
,[AscStatementData_SC_BSC]		 =GH.[AscStatementData_SC_BSC]
,[AscStatementData_MAC]		 =GH.[AscStatementData_MAC]
,[AscStatementData_MRC]		 =GH.[AscStatementData_MRC]
,[AscStatementData_TAC]		 =GH.[AscStatementData_TAC]
,[AscStatementData_GS_SC]=GH.[AscStatementData_GS_SC]
,[AscStatementData_GBS_BSC]=GH.[AscStatementData_GBS_BSC]
FROM #TempGUH GH 
JOIN AscStatementDataZoneMonthly GM on 
GM.AscStatementData_CongestedZoneID=GH.AscStatementData_CongestedZoneID and GM.AscStatementData_Year=GH.AscStatementData_Year and GM.AscStatementData_Month=GH.AscStatementData_Month and GM.AscStatementData_StatementProcessId=@StatementProcessId;


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
