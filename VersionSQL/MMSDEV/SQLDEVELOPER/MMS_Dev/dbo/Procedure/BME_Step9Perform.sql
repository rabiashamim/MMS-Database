/****** Object:  Procedure [dbo].[BME_Step9Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure [dbo].[BME_Step9Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	SET NOCOUNT ON;
	--------------------------------------------------------	
	------		MP Hourly Calculations
	--------------------------------------------------------
BEGIN TRY

     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN
-------------------------------------
---		Step 9.1	Calculate Hourly Settlement of Legacy
---		MP_SLR_1 = (ET_SLR1 / Total_ET_All_SLRs) * MP_Power_Pool_Hourly
--**********************************************************************
--DECLARE @Year int=2021,@Month int=11;

DROP TABLE if EXISTS #TempPowerPool
drop Table if Exists #TempEnergyTradedRatio

Select DISTINCT p.PartyRegisteration_Id 
INTO #TempPowerPool
From Bme_Parties p WHERE p.IsPowerPool=1;
-----------------------
select H.BmeStatementData_StatementProcessId, H.BmeStatementData_ContractId, h.BmeStatementData_BuyerPartyRegisteration_Id,h.BmeStatementData_BuyerPartyCategory_Code,h.BmeStatementData_CongestedZoneID ,h.BmeStatementData_NtdcDateTime
,(ISNULL( h.BmeStatementData_EnergyTradedBought,0)/ 
nullif(t.TotalEnergyTradedBought,0))
*ISNULL(
    (SELECT top (1) p.BmeStatementData_ImbalanceCharges from BmeStatementDataMpHourly p where 
     p.BmeStatementData_IsPowerPool=1 and H.BmeStatementData_NtdcDateTime=p.BmeStatementData_NtdcDateTime 
     and P.BmeStatementData_StatementProcessId= @StatementProcessId AND H.BmeStatementData_StatementProcessId= @StatementProcessId AND p.BmeStatementData_PartyRegisteration_Id in(select PartyRegisteration_Id from #TempPowerPool)
     )
     ,0) as ContractRatio
INTO #TempEnergyTradedRatio
 from BmeStatementDataMpContractHourly H
inner JOIN
(select MH.BmeStatementData_StatementProcessId, MH.BmeStatementData_NtdcDateTime, Sum(MH.BmeStatementData_EnergyTradedBought) as TotalEnergyTradedBought 
from BmeStatementDataMpContractHourly MH 

where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId and MH.BmeStatementData_ContractType_Id=4 
and MH.BmeStatementData_SellerPartyRegisteration_Id in(Select PartyRegisteration_Id From #TempPowerPool)

group BY MH.BmeStatementData_NtdcDateTime, MH.BmeStatementData_StatementProcessId) as t on
 H.BmeStatementData_NtdcDateTime=t.BmeStatementData_NtdcDateTime 
AND H.BmeStatementData_StatementProcessId=T.BmeStatementData_StatementProcessId

where H.BmeStatementData_Year=@Year and H.BmeStatementData_Month=@Month and H.BmeStatementData_StatementProcessId=@StatementProcessId and H.BmeStatementData_ContractType_Id=4 
and H.BmeStatementData_SellerPartyRegisteration_Id in(Select PartyRegisteration_Id From #TempPowerPool)
;

 update BmeStatementDataMpHourly set BmeStatementData_BSUPRatioPP=r.MPRatio
	From BmeStatementDataMpHourly MPH
	inner join	
	(select t.BmeStatementData_BuyerPartyRegisteration_Id,t.BmeStatementData_NtdcDateTime,T.BmeStatementData_StatementProcessId,
    sum(t.ContractRatio) as MPRatio from #TempEnergyTradedRatio t
    group BY t.BmeStatementData_BuyerPartyRegisteration_Id, t.BmeStatementData_NtdcDateTime,T.BmeStatementData_StatementProcessId
    ) as r on 
    MPH.BmeStatementData_PartyRegisteration_Id=r.BmeStatementData_BuyerPartyRegisteration_Id
     and MPH.BmeStatementData_NtdcDateTime=r.BmeStatementData_NtdcDateTime
     AND MPH.BmeStatementData_StatementProcessId=R.BmeStatementData_StatementProcessId

	where MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@month and MPH.BmeStatementData_StatementProcessId=@StatementProcessId


		------	Group Hourly MP_BSUP_Ratio to Monthly MP_BSUP_Ratio
		update  BmeStatementDataMpMonthly set BmeStatementData_SettlementOfLegacy=
		MPH.BmeStatementData_SettlementOfLegacy from BmeStatementDataMpMonthly MPM
		inner join
		(
		select Sum(MPH.BmeStatementData_BSUPRatioPP) as BmeStatementData_SettlementOfLegacy, MPH.BmeStatementData_PartyRegisteration_Id,MPH.BmeStatementData_StatementProcessId 
        from BmeStatementDataMpHourly MPH where 
		MPH.BmeStatementData_Year=@Year and  MPH.BmeStatementData_Month=@Month and MPH.BmeStatementData_StatementProcessId=@StatementProcessId 
		Group by MPH.BmeStatementData_PartyRegisteration_Id,MPH.BmeStatementData_StatementProcessId
		) as MPH
		on MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id
        AND MPH.BmeStatementData_StatementProcessId=MPM.BmeStatementData_StatementProcessId
        
		Where MPM.BmeStatementData_Year=@Year and  MPM.BmeStatementData_Month=@Month and MPM.BmeStatementData_StatementProcessId=@StatementProcessId;
		
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
