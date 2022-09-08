/****** Object:  Procedure [dbo].[ASCStepsOutputView_BK21June]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<AMMAMA GILL>
-- Create date: <09-MAY-2022>
-- Description:	<Description,,>
-- =============================================

--[dbo].[ASCStepsOutputView] 199,1
CREATE PROCEDURE [dbo].[ASCStepsOutputView_BK21June]
@pSettlementProcessId int,
@pStepId decimal(4,1)
AS 

BEGIN

DECLARE @BmeStatementProcessId decimal(18,0) = null;

SET @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@pSettlementProcessId);

-----1.Fetch SO data for ASC-------
IF(@pStepId=1)
BEGIN
	SELECT
	ROW_NUMBER() OVER (ORDER BY  GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,AscStatementData_SOUnitId) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,G.MtGenerator_Id AS [Generator ID]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
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
	WHERE GH.AscStatementData_StatementProcessId = @pSettlementProcessId
	--AND GH.AscStatementData_SO_MP IS NOT NULL
	--ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,MP_ID,[Generator ID],[Generation Unit Id];

END

-----2. Calculate Must Run MRC--------
ELSE IF (@pStepId = 2)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY  GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,AscStatementData_SOUnitId) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,G.MtGenerator_Id AS [Generator ID]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_MR_UPC AS [MR_UPC]
	   ,GH.AscStatementData_RG_EAG AS [RG_EAG]
	   ,GH.AscStatementData_AC_MOD AS [AC_MOD]
	   ,GH.AscStatementData_RG_LOCC AS [LOCC]
	   ,GH.AscStatementData_IG_EAG AS [IG_EAG]
	   ,GH.AscStatementData_SO_IG_EPG AS [IG_EPG]
	   ,GH.AscStatementData_IG_UPC AS [IG_UPC]
	   --,GH.AscStatementData_AC_Total AS [AC_Total]
	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,MP_ID,[Generator ID],[Generation Unit Id];

END

----- 3. Calculate Generation AC_Total ------
ELSE IF (@pStepId = 3)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,G.MtGenerationUnit_Id) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [hour]
	   ,G.MtPartyRegisteration_Id AS [MP_ID]
	   ,G.MtPartyRegisteration_Name AS [MP Name]
	   ,G.MtGenerator_Id AS [Generator ID]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
	   ,GH.AscStatementData_RG_EAG AS [RG_EAG]
	   ,GH.AscStatementData_SO_AC AS [AC]
	   ,GH.AscStatementData_AC_MOD AS [AC_MOD]
	   ,GH.AscStatementData_RG_LOCC AS [LOCC]
	   ,GH.AscStatementData_IG_EAG AS [IG_EAG]
	   ,GH.AscStatementData_SO_IG_EPG AS [IG_EPG]
	   ,GH.AscStatementData_IG_UPC AS [IG_UPC]
	   ,GH.AscStatementData_IG_AC AS [Increased Generation]
	   ,GH.AscStatementData_RG_AC AS [Reduced Generation]
	   ,GH.AscStatementData_AC_Total AS [AC_Total]
	FROM 
		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
	WHERE 
		GH.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,MP_ID,[Generator ID],[Generation Unit Id];
END

----- 6. Start Charges and Black Start Charges ----
--ELSE IF(@pStepId = 6)
--BEGIN
--	SELECT
--		ROW_NUMBER() OVER (ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,G.MtGenerationUnit_Id) AS [Sr]
--		,AscStatementData_Month AS [Month]
--	   ,AscStatementData_Day AS [Day]
--	   ,AscStatementData_Hour AS [hour]
--	   ,G.MtPartyRegisteration_Id AS [MP_ID]
--	   ,G.MtPartyRegisteration_Name AS [MP Name]
--	   ,G.MtGenerator_Id AS [Generator ID]
--	   ,G.MtGenerator_Name AS [Generator Name]
--	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
--	   , AscStatementData_UnitName AS [Generation Unit Name]
--	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
--	   ,GH.AscStatementData_MR_EAG AS [MR_EAG(kWh)]
--	   ,GH.AscStatementData_MR_EPG AS [MR_EPG (kWh)]
--	   ,GH.AscStatementData_MRC AS [Must Run Compensation (MRC)]
--	   ,GH.AscStatementData_SO_IG_VC AS [Increased Generation] -- confirm all below
--	   ,GH.AscStatementData_SO_RG_VC AS [Reduced Generation]
--	FROM 
--		[dbo].[AscStatementDataGuHourly_SettlementProcess] GH
--	JOIN [dbo].[ASC_GuParties] G
--		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId
--	JOIN MtCongestedZone mcz
--		ON mcz.MtCongestedZone_Id = GH.AscStatementData_CongestedZoneID
--	WHERE 
--		GH.AscStatementData_StatementProcessId = @pSettlementProcessId
--	--ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,MP_ID,[Generator ID],[Generation Unit Id];
--END

----- 4. Aggregate Must Run Generator Monthly -----
ELSE IF( @pStepId = 4)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY GM.AscStatementData_Year, GM.AscStatementData_Month,GM.AscStatementData_PartyRegisteration_Id,GM.AscStatementData_Generator_Id ) AS [Sr]
		,GM.AscStatementData_Month AS [month]
		,GM.AscStatementData_PartyRegisteration_Id AS [MP_ID]
	   ,GM.AscStatementData_PartyRegisteration_Name AS [MP Name]
	   ,Gm.AscStatementData_Generator_Id AS [Generator ID]
	   ,(SELECT TOP 1 mg.MtGenerator_Name FROM MtGenerator mg WHERE mg.MtGenerator_Id = Gm.AscStatementData_Generator_Id) AS [Generator Name]
	   
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GM.AscStatementData_MRC AS [Must Run Compensation (MRC)(PKR)]
	   
	FROM 
		[dbo].[AscStatementDataGenMonthly_SettlementProcess] GM
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GM.AscStatementData_CongestedZoneID
	WHERE 
		GM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY GM.AscStatementData_Year, GM.AscStatementData_Month,MP_ID,[Generator ID] ;
END

----- 5. The total amount of compensation for allowing the provision of Ancillary Services and Must Run Generation ---
ELSE IF (@pStepId = 5)
BEGIN


	SELECT 
		ROW_NUMBER() OVER (ORDER BY GM.AscStatementData_Year ,GM.AscStatementData_Month,GM.AscStatementData_PartyRegisteration_Id,GM.AscStatementData_Generator_Id) AS [Sr]
		,GM.AscStatementData_Month AS [month]
		,gm.AscStatementData_PartyRegisteration_Id AS [MP_ID]
	   ,gm.AscStatementData_PartyRegisteration_Name AS [MP Name]
	   ,Gm.AscStatementData_Generator_Id AS [Generator ID]
	  ,(SELECT TOP 1 mg.MtGenerator_Name FROM MtGenerator mg WHERE mg.MtGenerator_Id = Gm.AscStatementData_Generator_Id) AS [Generator Name]
	   
	   ,mcz.MtCongestedZone_Name AS [Congested Zone]
	   ,GM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
	   ,GM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
	   ,GM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
	   
	   
	   ,GM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
	   ,GM.AscStatementData_GBS_BSC AS [Black Start (PKR)] 
	   ,GM.AscStatementData_MAC AS [MAC_Total (PKR)]
	   
	FROM 
		[dbo].AscStatementDataGenMonthly_SettlementProcess GM
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = GM.AscStatementData_CongestedZoneID
		 
	WHERE 
		GM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY GM.AscStatementData_Year ,GM.AscStatementData_Month,MP_ID,[Generator ID];

END

---- 6. The total amount of compensation for allowing the provision of Ancillary Services and Must Run Generation in each Congested Zone ---
ELSE IF (@pStepId = 6)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Year,ZM.AscStatementData_Month) AS [Sr]
		,ZM.AscStatementData_Month AS [Month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,ZM.AscStatementData_GBS_BSC AS [Black Start (PKR)]
		,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]
	FROM 
		AscStatementDataZoneMonthly_SettlementProcess ZM
		JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = zm.AscStatementData_CongestedZoneID
	WHERE 
		ZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY
	--	ZM.AscStatementData_Year,ZM.AscStatementData_Month

END

------- 7. Calculation of Total Demand
ELSE IF (@pStepId = 7)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Year,MCH.BmeStatementData_Month,MCH.BmeStatementData_Day,MCH.BmeStatementData_Hour,MCH.BmeStatementData_PartyRegisteration_Id) AS [Sr]
		,BmeStatementData_Month AS [month]
		,BmeStatementData_Day AS [Day]
		,BmeStatementData_Hour AS [hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,mch.BmeStatementData_PartyName AS [MP Name]
		,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,MCH.BmeStatementData_EnergySuppliedActual AS [Act_E_ASC (kWh)] 
		,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]
		,MCH.BmeStatementData_EnergyTraded AS [Energy Traded (kWh)]
	FROM 
		BmeStatementDataMpCategoryHourly_SettlementProcess MCH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = MCH.BmeStatementData_CongestedZoneID
	WHERE 
		MCH.BmeStatementData_StatementProcessId = @BmeStatementProcessId
	--ORDER BY 
	--MCH.BmeStatementData_Year,MCH.BmeStatementData_Month,MCH.BmeStatementData_Day,MP_ID
END


----- 8. Calculation of Total Demand (Zone wise)
ELSE IF(@pStepId = 8)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Year,ZM.AscStatementData_Month) AS [Sr]
		,zm.AscStatementData_Month as [Month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,ZM.AscStatementData_SC_BSC [Black Start (PKR)]
		,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]
		,ZM.AscStatementData_TD AS [Total Demand (TD) (kWh)]
	FROM 
		AscStatementDataZoneMonthly_SettlementProcess ZM
		JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = ZM.AscStatementData_CongestedZoneID
	
	WHERE 
		ZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY
	--	ZM.AscStatementData_Year,ZM.AscStatementData_Month;
END

-------- 9. Category/Zone wise aggregated Receivables

ELSE IF(@pStepId = 9)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Year,CM.BmeStatementData_Month,CM.BmeStatementData_PartyRegisteration_Id) AS [Sr]
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
		BmeStatementDataMpCategoryMonthly_SettlementProcess CM
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = CM.BmeStatementData_CongestedZoneID
		WHERE 
			CM.BmeStatementData_StatementProcessId = @BmeStatementProcessId
	--ORDER BY 
	--	CM.BmeStatementData_Year,CM.BmeStatementData_Month,MP_ID
END

----------- 10.  Receivable determination of MP
ELSE IF(@pStepId = 10)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY CH.BmeStatementData_Year,CH.BmeStatementData_Month,CH.BmeStatementData_Day,CH.BmeStatementData_Hour,CH.BmeStatementData_PartyRegisteration_Id) AS [Sr]
		,CH.BmeStatementData_Month AS [Month]
		,CH.BmeStatementData_Day AS [Day]
		,CH.BmeStatementData_Hour AS [Hour]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,CH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]
		,CH.BmeStatementData_PartyName AS [MP Name]
		,CH.BmeStatementData_PartyCategory_Code AS [MP Category]
		,CH.BmeStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,CH.BmeStatementData_IG_AC AS [Increased Generation (PKR)]
		,CH.BmeStatementData_RG_AC AS [Reduced Generation (PKR)]
		,CH.BmeStatementData_GS_SC AS [Startup Cost (PKR)]
		,CH.BmeStatementData_GBS_BSC AS [Black Start (PKR)]
		,CH.BmeStatementData_TC AS [Total Cost (PKR)]
	FROM 
		BmeStatementDataMpCategoryHourly_SettlementProcess  CH
	JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = CH.BmeStatementData_CongestedZoneID
	WHERE CH.BmeStatementData_StatementProcessId = @BmeStatementProcessId
	AND CH.BmeStatementData_PartyType_Code = 'MP'
	--ORDER BY 
	--	CH.BmeStatementData_Year,CH.BmeStatementData_Month,MP_ID
END

----- 11. Aggregate Determined Receivables
ELSE IF(@pStepId = 11)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Year,CM.BmeStatementData_Month,CM.BmeStatementData_PartyRegisteration_Id) AS [Sr]
		,CM.BmeStatementData_Month AS [Month]
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
	WHERE CM.BmeStatementData_StatementProcessId = @BmeStatementProcessId
	--ORDER BY 
	--	CM.BmeStatementData_Year,CM.BmeStatementData_Month,MP_ID
END

----- 12. Aggregate MRC and ASC (Zone Wise and MP Wise)
ELSE IF(@pStepId = 12)
BEGIN
	
	DROP TABLE IF EXISTS #temp;

	SELECT 
		ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Year,MZM.AscStatementData_Year,MZM.AscStatementData_Month,MZM.AscStatementData_PartyRegisteration_Id) AS [Sr]
		,MZM.AscStatementData_Month AS [month]
		,MZM.AscStatementData_PartyRegisteration_Id AS [MP_ID]
		,MZM.AscStatementData_PartyName AS [MP Name]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		--,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
		,MZM.AscStatementData_GBS_BSC [Black Start (PKR)]
		,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]
		,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]
		
        /*,MZM.AscStatementData_TP_SOLR AS [Adjusted Payable (PKR)]*/
	INTO #temp
	FROM
		AscStatementDataMpZoneMonthly_SettlementProcess MZM
	JOIN MtCongestedZone mcz
	ON mcz.MtCongestedZone_Id = MZM.AscStatementData_CongestedZoneID
	WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY 
	--	MZM.AscStatementData_Year,MZM.AscStatementData_Month,MP_ID

		INSERT INTO #temp
		([month]
		,[MP Name]
		,[Payable (PKR)]
		,[Receivable (PKR)]
		)
	VALUES
	(
		''
		,'Total'
		,(SELECT ISNULL(SUM([Payable (PKR)]),0) FROM #temp)
		,(SELECT ISNULL(SUM([Receivable (PKR)]),0) FROM #temp)
	)

	--SELECT * FROM #temp;
	SELECT [Sr]	, case WHEN [Month]=0 THEN NULL else [Month] end	as [Month]	,[MP_ID],[MP Name],[Congested Zone]	,[Must Run Compensation (MRC) (PKR)],	[Increased Generation (PKR)],	[Reduced Generation (PKR)],[Startup Cost (PKR)],	[Black Start (PKR)],	[Payable (PKR)],[Receivable (PKR)]
 FROM #temp order by  case when [Sr] is null then 1 else 0 end, [SR]
;

END

------ 13. Calculation for the adjustment of Power Pool / Legacy Generation 21
ELSE IF(@pStepId = 13)
BEGIN
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Year,ZM.AscStatementData_Month) AS [Sr]
		,zm.AscStatementData_Month as [Month]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,ZM.AscStatementData_GBS_BSC [Black Start (PKR)]
		,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]
		,ZM.AscStatementData_TD AS [Total Demand (TD) (kWh)]
        ,ZM.AscStatementData_ES_BS AS  [Energy Supplied to BS (kWh)]
		,ZM.AscStatementData_KE_ES AS  [Energy Supplied to KE (kWh)]
		,ZM.AscStatementData_TP  [Total Payable (PKR)]
	FROM 
		AscStatementDataZoneMonthly_SettlementProcess ZM
		JOIN MtCongestedZone mcz
		ON mcz.MtCongestedZone_Id = ZM.AscStatementData_CongestedZoneID
	
	WHERE 
		ZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--ORDER BY
	--	ZM.AscStatementData_Year,ZM.AscStatementData_Month;
END

--14. Adjustment of Powerpool/Legacy generation (MP Zone-wise)
ELSE IF(@pStepId = 14)
BEGIN
	DROP TABLE IF EXISTS #tempPowerPool1

	SELECT 
		ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Year,MZM.AscStatementData_Month,MZM.AscStatementData_PartyRegisteration_Id) AS [Sr]
		,MZM.AscStatementData_Month AS [month]
		,MZM.AscStatementData_PartyRegisteration_Id AS [MP ID]
		,MZM.AscStatementData_PartyName AS [MP Name]
		,mcz.MtCongestedZone_Name AS [Congested Zone]
		,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		--,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
		,MZM.AscStatementData_GBS_BSC [Black Start (PKR)]
		,mzm.AscStatementData_ES AS [Energy Supplied (kWh)]
		,mzm.AscStatementData_TP_SOLR AS [Legacy Generation Adjustment (PKR)]
		,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]
		,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]
		
	INTO #tempPowerPool1
	FROM
		[dbo].AscStatementDataMpZoneMonthly_SettlementProcess  MZM
	JOIN MtCongestedZone mcz
	ON mcz.MtCongestedZone_Id = MZM.AscStatementData_CongestedZoneID
	
	WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--and MZM.AscStatementData_PartyRegisteration_Id <> 1115
	--ORDER BY 
	--	MZM.AscStatementData_Year,MZM.AscStatementData_Month,[MP ID]

		INSERT INTO #tempPowerPool1
		([month]	
		,[MP Name]
		,[Payable (PKR)]
		,[Receivable (PKR)]
		)
	VALUES
	(
		''
		,'Total'
		,(SELECT ISNULL(SUM([Payable (PKR)]),0) FROM #tempPowerPool1)
		,(SELECT ISNULL(SUM([Receivable (PKR)]),0) FROM #tempPowerPool1)
	)

	--SELECT * FROM #tempPowerPool pp
	SELECT [Sr]	, case WHEN [Month]=0 THEN NULL else [Month] end	as [Month],[MP ID]	,[MP Name],[Congested Zone]	,[Must Run Compensation (MRC) (PKR)],	[Increased Generation (PKR)],	[Reduced Generation (PKR)],[Startup Cost (PKR)],	[Black Start (PKR)]	,[Energy Supplied (kWh)],[Legacy Generation Adjustment (PKR)],	[Payable (PKR)],[Receivable (PKR)]
 FROM #tempPowerPool1 order by case when [Sr] is null then 1 else 0 end,[SR];
END

--- 15. MP wise ASC Payable and Receiveable with Settlement of Legacy 
ELSE IF(@pStepId = 15)
BEGIN
	DROP TABLE IF EXISTS #tempPowerPool

	SELECT 
		ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Year,MZM.AscStatementData_Month,MZM.AscStatementData_PartyRegisteration_Id) AS [Sr]
		,MZM.AscStatementData_Month AS [month]
		,MZM.AscStatementData_PartyRegisteration_Id AS [MP ID]
		,MZM.AscStatementData_PartyName AS [MP Name]
		,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		--,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
		,MZM.AscStatementData_GBS_BSC [Black Start (PKR)]
		,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]
		,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]
		
	INTO #tempPowerPool
	FROM
		[dbo].[AscStatementDataMpMonthly_SettlementProcess] MZM
	
	WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	--and MZM.AscStatementData_PartyRegisteration_Id <> 1115
	

		INSERT INTO #tempPowerPool
		([month]	
		,[MP Name]
		,[Payable (PKR)]
		,[Receivable (PKR)]
		)
	VALUES
	(
		''
		,'Total'
		,(SELECT ISNULL(SUM([Payable (PKR)]),0) FROM #tempPowerPool)
		,(SELECT ISNULL(SUM([Receivable (PKR)]),0) FROM #tempPowerPool)
	)

	--SELECT * FROM #tempPowerPool pp
	SELECT [Sr]	, case WHEN [Month]=0 THEN NULL else [Month] end	as [Month]	,[MP ID],[MP Name]	,[Must Run Compensation (MRC) (PKR)],	[Increased Generation (PKR)],	[Reduced Generation (PKR)],[Startup Cost (PKR)],	[Black Start (PKR)]	,	[Payable (PKR)],[Receivable (PKR)]
 FROM #tempPowerPool order by case when [Sr] is null then 1 else 0 end, [SR];
END

-- 16. Calculation of ESS Adjustment (For ESS Only)
ELSE IF(@pStepId = 16)
BEGIN
	Declare @vPredecessorId as decimal(18,0)

select @vPredecessorId=[dbo].[GetESSAdjustmentPredecessorStatementId](@pSettlementProcessId);

SELECT 
		ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Year,MZM.AscStatementData_Month,MZM.AscStatementData_PartyRegisteration_Id) AS [Sr]
		,MZM.AscStatementData_Month AS [Month]
		,MZM.AscStatementData_PartyRegisteration_Id AS [MP ID]
		,MZM.AscStatementData_PartyName AS [MP Name]
		,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]
		,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]
		,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]
		,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]
		,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]
		,MZM_Previous.AscStatementData_RECEIVABLE AS [Previous Month Receivable (PKR)]
		,MZM_Previous.AscStatementData_PAYABLE AS [Previous Month Payable (PKR)]
		,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]
		,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]
		,MZM.AscStatementData_AdjustmentRECEIVABLE as [Adjustment Receivable (PKR)]
		,MZM.AscStatementData_AdjustmentPAYABLE as [Adjustment Payable (PKR)]
	INTO #tempStep22
	FROM
		[dbo].[AscStatementDataMpMonthly_SettlementProcess] MZM
		 Join  [AscStatementDataMpMonthly_SettlementProcess] MZM_Previous on 
		 MZM.AscStatementData_PartyRegisteration_Id=MZM_Previous.AscStatementData_PartyRegisteration_Id
	
	WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	and MZM_Previous.AscStatementData_StatementProcessId=@vPredecessorId
	--and MZM.AscStatementData_PartyRegisteration_Id <> 1115
	--ORDER BY 
	--	MZM.AscStatementData_Month,MZM.AscStatementData_Year

	INSERT INTO #tempStep22
		([month]
		,[MP Name]
		,[Previous Month Receivable (PKR)]
		,[Previous Month Payable (PKR)]
		,[Receivable (PKR)]
		,[Payable (PKR)]
		,[Adjustment Receivable (PKR)]
		,[Adjustment Payable (PKR)]
		)
	VALUES
	(
		''
		,'Total'
		,(SELECT ISNULL(SUM([Previous Month Receivable (PKR)]),0) FROM #tempStep22)
		,(SELECT ISNULL(SUM([Previous Month Payable (PKR)]),0) FROM #tempStep22)
		,(SELECT ISNULL(SUM([Receivable (PKR)]),0) FROM #tempStep22)
		,(SELECT ISNULL(SUM([Payable (PKR)]),0) FROM #tempStep22)
		,(SELECT ISNULL(SUM([Adjustment Receivable (PKR)]),0) FROM #tempStep22)
		,(SELECT ISNULL(SUM([Adjustment Payable (PKR)]),0) FROM #tempStep22)
	)
	Declare @vPredecessorMonthName as NVARCHAR(MAX);
	select @vPredecessorMonthName=[dbo].[GetMonthNameFromMtStatementProcessId] (@vPredecessorId)

declare @query nvarchar(max);

set @query='select
	[Sr]	,case WHEN [Month]=0 THEN NULL else [Month] end	as [Month]	,[MP Name]	,[MP ID],	[Must Run Compensation (MRC) (PKR)],[Increased Generation (PKR)],[Reduced Generation (PKR)],[Startup Cost (PKR)], [Black Start (PKR)], [Payable (PKR)],[Receivable (PKR)],[Previous Month Payable (PKR)] as ['+@vPredecessorMonthName+' Payable (PKR)],[Previous Month Receivable (PKR)] as ['+@vPredecessorMonthName+' Receivable (PKR)],[Adjustment Payable (PKR)],[Adjustment Receivable (PKR)] from #tempStep22 order by case when [Sr] is null then 1 else 0 end, [Sr]
'
exec (@query);
 
END

END
