/****** Object:  Procedure [dbo].[BME_Step9Perform_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BME_Step9Perform_old](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	SET NOCOUNT ON;
	--------------------------------------------------------	
	------		MP Hourly Calculations
	--------------------------------------------------------

     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month)
    BEGIN
-------------------------------------
---		Step 9.1	Calculate Hourly Settlement of Legacy
---		MP_SLR_1 = (ET_SLR1 / Total_ET_All_SLRs) * MP_Power_Pool_Hourly
--**********************************************************************
--DECLARE @Year int=2021,@Month int=11;

DROP TABLE if EXISTS #TempPowerPool
drop Table if Exists #TempEnergyTradedRatio

Select distinct p.BmeStatementData_OwnerPartyRegisteration_Id 
INTO #TempPowerPool
From BmeStatementDataCdpOwnerParty p WHERE p.BmeStatementData_IsPowerPool=1;

select h.BmeStatementData_ContractId, h.BmeStatementData_BuyerPartyRegisteration_Id,h.BmeStatementData_NtdcDateTime
,(ISNULL( h.BmeStatementData_EnergyTradedBought,0)/ 
nullif(t.TotalEnergyTradedBought,0))
*ISNULL(
    (SELECT top (1) p.BmeStatementData_ImbalanceCharges from BmeStatementDataMpHourly p where 
     p.BmeStatementData_IsPowerPool=1 and H.BmeStatementData_NtdcDateTime=p.BmeStatementData_NtdcDateTime)
     ,0) as ContractRatio
INTO #TempEnergyTradedRatio
 from BmeStatementDataMpContractHourly H
inner JOIN
(select BmeStatementData_NtdcDateTime, Sum(MH.BmeStatementData_EnergyTradedBought) as TotalEnergyTradedBought 
from BmeStatementDataMpContractHourly MH where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month and MH.BmeStatementData_ContractType_Id=4 and MH.BmeStatementData_SellerPartyRegisteration_Id in(Select BmeStatementData_OwnerPartyRegisteration_Id From #TempPowerPool)
group BY  BmeStatementData_NtdcDateTime) as t on H.BmeStatementData_NtdcDateTime=t.BmeStatementData_NtdcDateTime 
where H.BmeStatementData_Year=@Year and H.BmeStatementData_Month=@Month and H.BmeStatementData_ContractType_Id=4 and H.BmeStatementData_SellerPartyRegisteration_Id in(Select BmeStatementData_OwnerPartyRegisteration_Id From #TempPowerPool)
;

 update BmeStatementDataMpHourly set BmeStatementData_BSUPRatioPP=r.MPRatio
	From BmeStatementDataMpHourly MPH
	inner join	
	(select t.BmeStatementData_BuyerPartyRegisteration_Id,t.BmeStatementData_NtdcDateTime, 
    sum(t.ContractRatio) as MPRatio from #TempEnergyTradedRatio t
    group BY t.BmeStatementData_BuyerPartyRegisteration_Id, t.BmeStatementData_NtdcDateTime
    ) as r on 
    MPH.BmeStatementData_PartyRegisteration_Id=r.BmeStatementData_BuyerPartyRegisteration_Id
     and MPH.BmeStatementData_NtdcDateTime=r.BmeStatementData_NtdcDateTime
    
	where MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@Month


-- select * from #TempSettlementLegacyCalculation


	 --**************************************************************************************


--SELECT * from BmeStatementDataMpHourly
END

	--------------------------------------------------------	
	------		9.2 MP Monthly Calculations --Settlement of Legacy Monthly
	--		Settlement of Legacy = Sum(MP_SLR_1)
	--------------------------------------------------------

   IF  EXISTS(SELECT TOP 1 BmeStatementData_Id FROM [BmeStatementDataMpMonthly] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month)
    BEGIN
	
		------	Group Hourly MP_BSUP_Ratio to Monthly MP_BSUP_Ratio
		update  BmeStatementDataMpMonthly set BmeStatementData_SettlementOfLegacy=
		MPH.BmeStatementData_SettlementOfLegacy from BmeStatementDataMpMonthly MPM
		inner join
		(
		select Sum(MPH.BmeStatementData_BSUPRatioPP) as BmeStatementData_SettlementOfLegacy, BmeStatementData_PartyRegisteration_Id 
        from BmeStatementDataMpHourly MPH where 
		MPH.BmeStatementData_Year=@Year and  MPH.BmeStatementData_Month=@Month 
		Group by MPH.BmeStatementData_PartyRegisteration_Id
		) as MPH
		on MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id
		Where MPM.BmeStatementData_Year=@Year and  MPM.BmeStatementData_Month=@Month;

		

	END
	SELECT 1;
-----------------------------------------
END
