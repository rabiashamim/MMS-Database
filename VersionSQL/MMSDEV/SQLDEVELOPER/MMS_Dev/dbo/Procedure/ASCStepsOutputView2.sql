/****** Object:  Procedure [dbo].[ASCStepsOutputView2]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<AMMAMA GILL>
-- Create date: <09-MAY-2022>
-- Description:	<Description,,>
-- =============================================

--[dbo].[ASCStepsOutputView] 22,21
CREATE PROCEDURE [dbo].[ASCStepsOutputView2]
@pSettlementProcessId int,
@pStepId decimal(4,1)
AS 

BEGIN

-----1. Fetch SO Generator Start -------
IF(@pStepId=1)
BEGIN
	SELECT
	ROW_NUMBER() OVER (ORDER BY gh.AscStatementData_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_SO_MP AS [Marginal Price]
	   ,GH.AscStatementData_SO_AC AS [AC_Actual Available Capacity]
	   ,GH.AscStatementData_SO_AC_ASC AS [AC_Available Capacity for ASC]
	   ,GH.AscStatementData_MR_EPG AS [MR_Energy produced (MWh) in case no congestion]
	   ,GH.AscStatementData_SO_MR_VC AS [MR_Variable Cost]
	   ,GH.AscStatementData_SO_RG_UT AS [RG_Generation Unit Type (Thermal/ARE)]
	   ,GH.AscStatementData_SO_RG_VC [RG_Variable Generation Cost ]
	   ,GH.AscStatementData_SO_RG_EG_ARE [RG_Expected Energy Generation in Case of ARE]
	   ,GH.AscStatementData_SO_IG_VC [IG_Variable Generation Cost ] 
	   ,GH.AscStatementData_SO_IG_EPG AS [IG_Energy that would be produced if no ASC ]
	   

	FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE GH.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour;

END

-----2. Calculate Must Run MRC --------
ELSE IF (@pStepId = 2)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY gh.AscStatementData_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_RG_EAG AS [RG_EAG]
	   ,GH.AscStatementData_AC_MOD AS [AC_MOD]
	   ,GH.AscStatementData_RG_LOCC AS [LOCC]
	   ,GH.AscStatementData_IG_EAG AS [IG_EAG]
	   ,GH.AscStatementData_SO_IG_EPG AS [IG_EPG]
	   ,GH.AscStatementData_IG_UPC AS [IG_UPC]
	   ,GH.AscStatementData_AC_Total AS [AC_Total]
	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour;

END

----- 3. Calculate LOCC -----
ELSE IF (@pStepId = 3)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY gh.AscStatementData_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_RG_EAG AS [RG_EAG]
	   ,GH.AscStatementData_AC_MOD AS [AC_MOD]
	   ,GH.AscStatementData_RG_LOCC AS [LOCC]
	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour;
END

----- 4. Calculate Increased Generation UPC ------
ELSE IF (@pStepId = 4)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY gh.AscStatementData_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_RG_EAG AS [RG_EAG]
	   ,GH.AscStatementData_AC_MOD AS [AC_MOD]
	   ,GH.AscStatementData_RG_LOCC AS [LOCC]
	   ,GH.AscStatementData_IG_EAG AS [IG_EAG]
	   ,GH.AscStatementData_SO_IG_EPG AS [IG_EPG]
	   ,GH.AscStatementData_IG_UPC AS [IG_UPC]

	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour;
END

----- 5. Calculate Generation AC_Total ------
ELSE IF (@pStepId = 5)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY gh.AscStatementData_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_RG_EAG AS [RG_EAG]
	   ,GH.AscStatementData_AC_MOD AS [AC_MOD]
	   ,GH.AscStatementData_RG_LOCC AS [LOCC]
	   ,GH.AscStatementData_IG_EAG AS [IG_EAG]
	   ,GH.AscStatementData_SO_IG_EPG AS [IG_EPG]
	   ,GH.AscStatementData_IG_UPC AS [IG_UPC]
	   ,GH.AscStatementData_AC_Total AS [AC_Total]
	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour;
END

----- 6. Start Charges and Black Start Charges ----
ELSE IF(@pStepId = 6)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY gh.AscStatementData_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_SO_IG_VC AS [Increased Generation] -- confirm all below
	   ,GH.AscStatementData_SO_RG_VC AS [Reduced Generation]
	   ,'' AS [Startup Cost]
	   ,'' AS [Black Start]
	   ,'' AS [Total]
	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour;
END

----- 7. Aggregate Must Run Generator Monthly -----
ELSE IF( @pStepId = 7)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY GM.AscStatementData_Id) AS [Sr]
		,GM.AscStatementData_Month AS [month]
	   --,AscStatementData_Day AS [Day]
	   --,AscStatementData_Hour AS [Hour]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GM.AscStatementData_MRC AS [Must Run Compensation (MRC)(PKR)]
	   
	FROM 
		[dbo].[AscStatementDataGenMonthly_SettlementProcess] GM
	JOIN [dbo].[ASC_GuParties] G
		ON GM.AscStatementData_Generator_Id = G.MtGenerator_Id
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GM.AscStatementData_CongestedZoneID
	WHERE 
		GM.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GM.AscStatementData_Month, GM.AscStatementData_Year;
END

----- 8. The total amount of compensation for allowing the provision of Ancillary Services and Must Run Generation ---
ELSE IF (@pStepId = 8)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY GM.AscStatementData_Id) AS [Sr]
		,GM.AscStatementData_Month AS [Month]
	   --,AscStatementData_Day AS [Day]
	   --,AscStatementData_Hour AS [Hour]
	   --,AscStatementData_SOUnitId AS [Generation Unit Id]
	   --, AscStatementData_UnitName AS [Generation Unit Name]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
	   ,GM.AscStatementData_SO_IG_VC AS [Increased Generation (PKR)]
	   ,GM.AscStatementData_SO_RG_VC AS [Reduced Generation (PKR)]
	   ,'' AS [Startup Cost (PKR)]
	   ,GM.AscStatementData_SC_BSC AS [Black Start (PKR)] 
	   ,GM.AscStatementData_AC_Total AS [Total (PKR)]
	FROM 
		[dbo].AscStatementDataGenMonthly_SettlementProcess GM
	JOIN [dbo].[ASC_GuParties] G
		ON GM.AscStatementData_Generator_Id = G.MtGenerator_Id
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GM.AscStatementData_CongestedZoneID
		 
	WHERE 
		GM.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY GM.AscStatementData_Year ,GM.AscStatementData_Month;
END

---- 9. The total amount of compensation for allowing the provision of Ancillary Services and Must Run Generation in each Congested Zone ---
ELSE IF (@pStepId = 9)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Id) AS [Sr]
		,ZM.AscStatementData_Month AS [Month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,'' AS [Startup Cost (PKR)]
		,ZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
		,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC)]
	FROM 
		AscStatementDataZoneMonthly_SettlementProcess ZM
		JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = zm.AscStatementData_CongestedZoneID
	ORDER BY
		ZM.AscStatementData_Month,ZM.AscStatementData_Year

END

---- 10. Calculation of the Energy Supplied by Each Market Participant Category
ELSE IF (@pStepId = 10)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_ActualEnergy AS [Act_E_ASC (kWh)] -- confirm
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	ORDER BY 
	MCH.BmeStatementData_Day,MCH.BmeStatementData_Month,MCH.BmeStatementData_Year
END

----- 11. Demand BPC
ELSE IF (@pStepId = 11)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_ActualEnergy AS [Act_E_ASC (kWh)] -- confirm
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
		,'' AS [ES_BPC (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	ORDER BY 
	MCH.BmeStatementData_Day,MCH.BmeStatementData_Month,MCH.BmeStatementData_Year
END

---- 12. Demand Generator
ELSE IF(@pStepId = 12)
BEGIN 
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_ActualEnergy AS [Act_E_ASC (kWh)] -- confirm
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
		,MCH.BmeStatementData_EnergySuppliedGenerated AS [ES_Gen (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	ORDER BY 
	MCH.BmeStatementData_Day,MCH.BmeStatementData_Month,MCH.BmeStatementData_Year
END 

---- 13. Demand Competitive Supplier
ELSE IF(@pStepId = 13)
BEGIN 
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_ActualEnergy AS [Act_E_ASC (kWh)] -- confirm
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
		,'' AS [ES_CS (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	ORDER BY 
	MCH.BmeStatementData_Day,MCH.BmeStatementData_Month,MCH.BmeStatementData_Year
END

---- 14. Demand Base Supplier 
ELSE IF(@pStepId = 14)
BEGIN 
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_ActualEnergy AS [Act_E_ASC (kWh)] -- confirm
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
		,'' AS [ES_BS (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	ORDER BY 
	MCH.BmeStatementData_Day,MCH.BmeStatementData_Month,MCH.BmeStatementData_Year
END

------- 15. Demand of Trader
ELSE IF (@pStepId = 15)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_ActualEnergy AS [Act_E_ASC (kWh)] -- confirm
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
		,MCH.BmeStatementData_EnergyTraded AS [ES_Trader (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	ORDER BY 
	MCH.BmeStatementData_Day,MCH.BmeStatementData_Month,MCH.BmeStatementData_Year
END


----- 16. Calculation of Total Demand
ELSE IF(@pStepId = 16)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Id) AS [Sr]
		,ZM.AscStatementData_Congestion_Zone AS [Congested Zone]
		,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,ZM.AscStatementData_SC_BSC [Black Start (PKR)]
		,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]
		,ZM.AscStatementData_TD AS [Total Demand (TD) (PKR)]
	FROM 
		AscStatementDataZoneMonthly_SettlementProcess ZM
	
	WHERE 
		ZM.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY
		ZM.AscStatementData_Month,ZM.AscStatementData_Year;
END

-------- 17. Receivable determination Black Start

ELSE IF(@pStepId = 17)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Id) AS [Sr]
		,CM.BmeStatementData_Month AS [month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,CM.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,cm.BmeStatementData_PartyName AS [MP Name]
		,CM.BmeStatementData_PartyCategory_Code AS [MP Category]
		,CM.BmeStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,CM.BmeStatementData_IG_AC AS [Increased Generation (PKR)]
		,CM.BmeStatementData_RG_AC AS [Reduced Generation (PKR)]
		,CM.BmeStatementData_GS_SC AS [Startup Cost (PKR)]
		,CM.BmeStatementData_GBS_BSC AS [Black Start (PKR)]
	FROM 
		BmeStatementDataMpCategoryMonthly CM
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = CM.BmeStatementData_CongestedZoneID
	ORDER BY 
		CM.BmeStatementData_Month,CM.BmeStatementData_Year
END

----------- 18. Receivable determination for Trader
ELSE IF(@pStepId = 18)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Id) AS [Sr]
		,CM.BmeStatementData_Month AS [month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,CM.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,cm.BmeStatementData_PartyName AS [MP Name]
		,CM.BmeStatementData_PartyCategory_Code AS [MP Category]
		,CM.BmeStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,CM.BmeStatementData_IG_AC AS [Increased Generation (PKR)]
		,CM.BmeStatementData_RG_AC AS [Reduced Generation (PKR)]
		,CM.BmeStatementData_GS_SC AS [Startup Cost (PKR)]
		,CM.BmeStatementData_GBS_BSC AS [Black Start (PKR)]
		,'' AS [Total Cost BPC (PKR)]
		,'' AS [Total Cost Gen (PKR)]
		,'' AS [Total Cost CS (PKR)]
		,'' AS [Total Cost BS (PKR)]
		,CM.BmeStatementData_TC AS [Total Cost Trader (PKR)]
	FROM 
		BmeStatementDataMpCategoryMonthly CM
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = CM.BmeStatementData_CongestedZoneID
	ORDER BY 
		CM.BmeStatementData_Month,CM.BmeStatementData_Year
END

----- 19. Aggregate Determined Receivables
ELSE IF(@pStepId = 19) -- CONFIRM
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Id) AS [Sr]
		,CM.BmeStatementData_Month AS [month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,CM.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,cm.BmeStatementData_PartyName AS [MP Name]
		,CM.BmeStatementData_PartyCategory_Code AS [MP Category]
		,CM.BmeStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,CM.BmeStatementData_IG_AC AS [Increased Generation (PKR)]
		,CM.BmeStatementData_RG_AC AS [Reduced Generation (PKR)]
		,CM.BmeStatementData_GS_SC AS [Startup Cost (PKR)]
		,CM.BmeStatementData_GBS_BSC AS [Black Start (PKR)]
	FROM 
		BmeStatementDataMpCategoryMonthly CM
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = CM.BmeStatementData_CongestedZoneID
	ORDER BY 
		CM.BmeStatementData_Month,CM.BmeStatementData_Year
END

----- 20. Aggregate MRC and ASC
ELSE IF(@pStepId = 20)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Id) AS [Sr]
		,MZM.AscStatementData_Month AS [month]
		,MZM.AscStatementData_PartyRegisteration_Id AS [MP_ID]
		,MZM.AscStatementData_PartyName AS [MP Name]
		,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
	FROM
		AscStatementDataMpZoneMonthly_SettlementProcess MZM
	WHERE MZM.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY 
		MZM.AscStatementData_Month,MZM.AscStatementData_Year
END

------ 21. Aggregate MRC and ASC
ELSE IF(@pStepId = 21)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Id) AS [Sr]
		,MZM.AscStatementData_Month AS [month]
		,MZM.AscStatementData_PartyRegisteration_Id AS [MP_ID]
		,MZM.AscStatementData_PartyName AS [MP Name]
		,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
		,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]
		,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]
	FROM
		[dbo].[AscStatementDataMpMonthly_SettlementProcess] MZM
	WHERE MZM.AscStatementData_SettlementProcessId = @pSettlementProcessId
	ORDER BY 
		MZM.AscStatementData_Month,MZM.AscStatementData_Year
END

END
