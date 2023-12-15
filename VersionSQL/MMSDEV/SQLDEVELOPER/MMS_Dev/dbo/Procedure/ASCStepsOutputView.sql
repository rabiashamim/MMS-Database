/****** Object:  Procedure [dbo].[ASCStepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================          
-- Author:  <AMMAMA GILL>          
-- Create date: <09-MAY-2022>          
-- Description: <Description,,>          
-- =============================================          
--dbo.ASCStepsOutputView 237,15          
--dbo.ASCStepsOutputView 217,15          
CREATE   Procedure dbo.ASCStepsOutputView          
@pSettlementProcessId int,          
@pStepId decimal(4,1)          
AS           
          
BEGIN          
          
DECLARE @BmeStatementProcessId decimal(18,0) = null;          
          
SET @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@pSettlementProcessId);          
DECLARE @vSrProcessDef_ID DECIMAL(18,0);          
SELECT @vSrProcessDef_ID=SrProcessDef_ID FROM MtStatementProcess WHERE MtStatementProcess_ID=@pSettlementProcessId AND ISNULL(MtStatementProcess_IsDeleted,0)=0          
          
-----1.Fetch SO data for ASC-------          
IF(@pStepId=1)          
BEGIN          
 SELECT          
 ROW_NUMBER() OVER (ORDER BY  GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,AscStatementData_SOUnitId) AS [Sr]          
  ,AscStatementData_Month AS [Month]          
    ,AscStatementData_Day AS [Day]          
    ,AscStatementData_Hour -1 AS [Hour]          
    ,G.MtPartyRegisteration_Id AS [MP_ID]          
    ,G.MtPartyRegisteration_Name AS [MP Name]          
    ,G.MtGenerator_Id AS [Generator ID]          
    ,G.MtGenerator_Name AS [Generator Name]          
    ,AscStatementData_SOUnitId AS [Generation Unit Id]          
    , AscStatementData_UnitName AS [Generation Unit Name]          
--    ,GH.AscStatementData_CongestedZone AS [Congested Zone]          
, (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=GH.AscStatementData_CongestedZoneID) AS [Congested Zone]          
   ,GH.AscStatementData_SO_MP AS [Marginal Price]     
       
,Format(GH.AscStatementData_SO_AC,'N') AS [AC_Actual Available Capacity]        
,Format(GH.AscStatementData_SO_AC_ASC,'N') AS [AC_Available Capacity for ASC]        
,Format(GH.AscStatementData_MR_EPG ,'N') AS [MR_Energy produced (MWh) in case no congestion]        
,Format(GH.AscStatementData_SO_MR_VC ,'N') AS [MR_Variable Cost]        
,GH.AscStatementData_SO_RG_UT AS [RG_Generation Unit Type (Thermal/ARE)]            
,Format(GH.AscStatementData_SO_RG_VC,'N') AS [RG_Variable Generation Cost ]        
,Format(GH.AscStatementData_SO_RG_EG_ARE,'N') AS [RG_Expected Energy Generation in Case of ARE]        
,Format(GH.AscStatementData_SO_IG_VC,'N') AS [IG_Variable Generation Cost ]         
,Format(GH.AscStatementData_SO_IG_EPG ,'N') AS [IG_Energy that would be produced if no ASC ]        
   
 FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] GH          
 JOIN [dbo].[ASC_GuParties] G          
ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId           
 WHERE GH.AscStatementData_StatementProcessId = @pSettlementProcessId          
           
END          
          
-----2. Calculate Must Run MRC--------          
ELSE IF (@pStepId = 2)          
BEGIN          

          
          
           
SELECT            
  AscStatementData_Month           
    ,AscStatementData_Day           
    ,AscStatementData_Hour           
    ,AscStatementData_SOUnitId            
    , AscStatementData_UnitName           
      ,AscStatementData_SO_RG_VC          
   ,AscStatementData_SO_IG_VC          
   ,AscStatementData_SO_MR_VC          
   ,AscStatementData_SO_MP          
    ,GH.AscStatementData_MR_EAG           
    ,GH.AscStatementData_MR_EPG           
    ,GH.AscStatementData_MRC           
    ,GH.AscStatementData_MR_UPC          
    ,GH.AscStatementData_RG_EAG           
    ,GH.AscStatementData_AC_MOD           
    ,GH.AscStatementData_RG_LOCC          
    ,GH.AscStatementData_IG_EAG           
    ,GH.AscStatementData_SO_IG_EPG           
    ,GH.AscStatementData_IG_UPC           
    ,GH.AscStatementData_AC_Total          
    ,GH.AscStatementData_CongestedZoneID            
,(select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=GH.AscStatementData_CongestedZoneID) AS AscStatementData_CongestedZone          
    ,GH.AscStatementData_StatementProcessId          
    INTO #temp1           
 FROM           
  [dbo].[AscStatementDataGuHourly_SettlementProcess] GH          
 WHERE           
  GH.AscStatementData_StatementProcessId = @pSettlementProcessId          
          
          
SELECT          
  ROW_NUMBER() OVER (ORDER BY  GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,AscStatementData_SOUnitId) AS [Sr] --G.MtPartyRegisteration_Id,G.MtGenerator_Id,          
  ,AscStatementData_Month AS [Month]          
    ,AscStatementData_Day AS [Day]          
    ,AscStatementData_Hour -1 AS [Hour]          
    ,G.MtPartyRegisteration_Id AS [MP_ID]          
    ,G.MtPartyRegisteration_Name AS [MP Name]          
    ,G.MtGenerator_Id AS [Generator ID]          
    ,G.MtGenerator_Name AS [Generator Name]          
    ,AscStatementData_SOUnitId AS [Generation Unit Id]          
    , AscStatementData_UnitName AS [Generation Unit Name]          
    ,GH.AscStatementData_CongestedZone AS [Congested Zone]          
   ,AscStatementData_SO_MP AS MP          
        
--MR    
,Format(GH.AscStatementData_MR_EAG  ,'N') AS [MR_EAG(kWh)]          
,Format(GH.AscStatementData_MR_EPG  ,'N') AS [MR_EPG (kWh)]          
,Format(GH.AscStatementData_MRC  ,'N') AS [Must Run Compensation (MRC)]          
,Format(GH.AscStatementData_MR_UPC  ,'N') AS [MR_UPC]          
,Format(AscStatementData_SO_MR_VC   ,'N') AS [MR_VC]          
    
 --RG      
,Format(GH.AscStatementData_RG_EAG  ,'N') AS [RG_EAG]          
,Format(AscStatementData_SO_RG_VC  ,'N') AS [RG_VC]          
,Format(GH.AscStatementData_AC_MOD  ,'N') AS [AC_MOD]          
,Format(GH.AscStatementData_RG_LOCC  ,'N') AS [LOCC]          
 --IG     
,Format(GH.AscStatementData_IG_EAG ,'N') AS [IG_EAG]          
,Format(GH.AscStatementData_SO_IG_EPG  ,'N') AS [IG_EPG]          
,Format(GH.AscStatementData_IG_UPC  ,'N') AS [IG_UPC]          
,Format(AscStatementData_SO_IG_VC   ,'N') AS [IG_VC]          
,Format(GH.AscStatementData_AC_Total  ,'N') AS [AC_Total]       
    
     
 FROM           
  #temp1 GH          
 JOIN [dbo].[ASC_GuParties] G          
  ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId          
           
          
END          
          
----- 3. Calculate Generation AC_Total ------          
ELSE IF (@pStepId = 3)          
BEGIN          
          

 DROP TABLE IF EXISTS #temp3          
          
SELECT          
            
  AscStatementData_Month           
    ,AscStatementData_Day           
    ,AscStatementData_Hour           
    ,AscStatementData_SOUnitId           
    , AscStatementData_UnitName          
   ,AscStatementData_SO_MP          
   ,AscStatementData_SO_RG_VC          
   ,AscStatementData_SO_IG_VC          
   ,AscStatementData_SO_MR_VC          
      ,GH.AscStatementData_MR_EAG          
    ,GH.AscStatementData_MR_EPG          
    ,GH.AscStatementData_MRC           
    ,GH.AscStatementData_RG_EAG           
    ,GH.AscStatementData_SO_AC          
    ,GH.AscStatementData_AC_MOD           
    ,GH.AscStatementData_RG_LOCC          
    ,GH.AscStatementData_IG_EAG          
    ,GH.AscStatementData_SO_IG_EPG           
    ,GH.AscStatementData_IG_UPC           
    ,GH.AscStatementData_IG_AC           
    ,GH.AscStatementData_RG_AC           
    --,GH.AscStatementData_AC_Total           
    ,ISNULL(GH.AscStatementData_AC_Total,0)+ISNULL(AscStatementData_MRC,0) AS AscStatementData_AC_Total          
    ,GH.AscStatementData_CongestedZoneID          
       ,(select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=GH.AscStatementData_CongestedZoneID) AS AscStatementData_CongestedZone          
            
   INTO #temp3          
 FROM           
  [dbo].[AscStatementDataGuHourly_SettlementProcess] GH          
 WHERE           
  GH.AscStatementData_StatementProcessId = @pSettlementProcessId          
  AND ISNULL(GH.AscStatementData_AC_Total,0) != 0        


-- 3.1

SELECT          
  ROW_NUMBER() OVER (ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,G.MtGenerationUnit_Id) AS [Sr]          
  ,AscStatementData_Month AS [Month]          
    ,AscStatementData_Day AS [Day]          
    ,AscStatementData_Hour -1 AS [Hour]          
    ,G.MtPartyRegisteration_Id AS [MP_ID]          
    ,G.MtPartyRegisteration_Name AS [MP Name]          
    ,G.MtGenerator_Id AS [Generator ID]          
    ,G.MtGenerator_Name AS [Generator Name]          
    ,AscStatementData_SOUnitId AS [SO Unit Id]          
    , AscStatementData_UnitName AS [Generation Unit Name]          
    ,GH.AscStatementData_CongestedZone AS [Congested Zone]          
    ,AscStatementData_SO_MP AS MP    
--MR     
,Format(GH.AscStatementData_MR_EAG,'N') AS [MR_EAG(kWh)]          
,Format(GH.AscStatementData_MR_EPG,'N') AS [MR_EPG (kWh)]          
,Format(AscStatementData_SO_MR_VC,'N') AS [MR_VC]         
,Format(GH.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC)]          
--RG     
,Format(GH.AscStatementData_RG_EAG,'N') AS [RG_EAG]          
,Format(GH.AscStatementData_SO_AC,'N') AS [AC]          
,Format(GH.AscStatementData_AC_MOD,'N') AS [AC_MOD]          
,Format(GH.AscStatementData_RG_LOCC,'N') AS [LOCC]          
,Format(AscStatementData_SO_RG_VC,'N') AS [RG_VC]          
,Format(GH.AscStatementData_RG_AC,'N') AS [Reduced Generation]          
--IG    
,Format(GH.AscStatementData_IG_EAG,'N') AS [IG_EAG]          
,Format(GH.AscStatementData_SO_IG_EPG  ,'N') AS [IG_EPG]          
,Format(GH.AscStatementData_IG_UPC ,'N') AS [IG_UPC]          
,Format(AscStatementData_SO_IG_VC,'N') AS [IG_VC]          
,Format(GH.AscStatementData_IG_AC,'N') AS [Increased Generation]      
    
,Format(GH.AscStatementData_AC_Total  ,'N') AS [AC_Total]    
    
         
 FROM           
  #temp3 GH          
 JOIN [dbo].[ASC_GuParties] G          
  ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId          
           
       
-- 3.2
SELECT          
  ROW_NUMBER() OVER (ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,G.MtGenerationUnit_Id) AS [Sr]          
  ,AscStatementData_Month AS [Month]          
    ,AscStatementData_Day AS [Day]          
    ,AscStatementData_Hour -1 AS [Hour]          
    ,G.MtPartyRegisteration_Id AS [MP_ID]          
    ,G.MtPartyRegisteration_Name AS [MP Name]          
    ,G.MtGenerator_Id AS [Generator ID]          
    ,G.MtGenerator_Name AS [Generator Name]          
    ,AscStatementData_SOUnitId AS [SO Unit Id]          
    , AscStatementData_UnitName AS [Generation Unit Name]          
    ,GH.AscStatementData_CongestedZone AS [Congested Zone]          
    ,AscStatementData_SO_MP AS MP    
--MR     
,Format(GH.AscStatementData_MR_EAG,'N') AS [MR_EAG(kWh)]          
,Format(GH.AscStatementData_MR_EPG,'N') AS [MR_EPG (kWh)]          
,Format(AscStatementData_SO_MR_VC,'N') AS [MR_VC]         
,Format(GH.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC)]          
--RG     
,Format(GH.AscStatementData_RG_EAG,'N') AS [RG_EAG]          
,Format(GH.AscStatementData_SO_AC,'N') AS [AC]          
,Format(GH.AscStatementData_AC_MOD,'N') AS [AC_MOD]          
,Format(GH.AscStatementData_RG_LOCC,'N') AS [LOCC]          
,Format(AscStatementData_SO_RG_VC,'N') AS [RG_VC]          
,Format(GH.AscStatementData_RG_AC,'N') AS [Reduced Generation]          
--IG    
,Format(GH.AscStatementData_IG_EAG,'N') AS [IG_EAG]          
,Format(GH.AscStatementData_SO_IG_EPG  ,'N') AS [IG_EPG]          
,Format(GH.AscStatementData_IG_UPC ,'N') AS [IG_UPC]          
,Format(AscStatementData_SO_IG_VC,'N') AS [IG_VC]          
,Format(GH.AscStatementData_IG_AC,'N') AS [Increased Generation]      
    
,Format(GH.AscStatementData_AC_Total  ,'N') AS [AC_Total]    
          
 FROM           
  #temp3 GH          
 JOIN [dbo].[ASC_GuParties] G          
  ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId          
 WHERE 
ISNULL(GH.AscStatementData_AC_Total,0) >= 0 
 

END          
      
          
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
              
    ,--GM.AscStatementData_CongestedZone AS [Congested Zone]          
    (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=GM.AscStatementData_CongestedZoneID) AS [Congested Zone]          
          
    ,GM.AscStatementData_MRC AS [Must Run Compensation (MRC)(PKR)]          
              
 FROM           
  [dbo].[AscStatementDataGenMonthly_SettlementProcess] GM           
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
    ,--GM.AscStatementData_CongestedZone AS [Congested Zone]          
 (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=GM.AscStatementData_CongestedZoneID) AS [Congested Zone]          
          
 ,Format(GM.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC) (PKR)]          
 ,Format(GM.AscStatementData_IG_AC,'N') AS [Increased Generation (PKR)]          
 ,Format(GM.AscStatementData_RG_AC,'N') AS [Reduced Generation (PKR)]          
    
 ,Format(GM.AscStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
 ,Format(GM.AscStatementData_GBS_BSC,'N') AS [Black Start (PKR)]           
 ,Format(GM.AscStatementData_MAC,'N') AS [MAC_Total (PKR)    
    
    --,GM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
    --,GM.AscStatementData_IG_AC AS [Increased Generation (PKR)]          
    --,GM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]          
              
              
    --,GM.AscStatementData_GS_SC AS [Startup Cost (PKR)]          
    --,GM.AscStatementData_GBS_BSC AS [Black Start (PKR)]           
    --,GM.AscStatementData_MAC AS [MAC_Total (PKR)]          
              
 FROM           
  [dbo].AscStatementDataGenMonthly_SettlementProcess GM          
           
 WHERE           
  GM.AscStatementData_StatementProcessId = @pSettlementProcessId         
  AND ISNULL(GM.AscStatementData_MAC,0) > 0          
 --ORDER BY GM.AscStatementData_Year ,GM.AscStatementData_Month,MP_ID,[Generator ID];          
          
END          
          
---- 6. The total amount of compensation for allowing the provision of Ancillary Services and Must Run Generation in each Congested Zone ---          
ELSE IF (@pStepId = 6)          
BEGIN          
 SELECT           
  ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Year,ZM.AscStatementData_Month) AS [Sr]          
  ,ZM.AscStatementData_Month AS [Month]          
  ,--zm.AscStatementData_CongestedZone AS [Congested Zone]          
    (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=ZM.AscStatementData_CongestedZoneID) AS [Congested Zone]          
          
,Format(ZM.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC) (PKR)]          
,Format(ZM.AscStatementData_IG_AC,'N') AS [Increased Generation (PKR)]          
,Format(ZM.AscStatementData_RG_AC,'N') AS [Reduced Generation (PKR)]          
,Format(ZM.AscStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
,Format(ZM.AscStatementData_GBS_BSC,'N') AS [Black Start (PKR)]          
,Format(ZM.AscStatementData_TAC,'N') AS [Total Amount of Compensation (TAC) (PKR)]     
    
  --,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
  --,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]          
  --,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]          
  --,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,ZM.AscStatementData_GBS_BSC AS [Black Start (PKR)]          
  --,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]          
 FROM           
  AscStatementDataZoneMonthly_SettlementProcess ZM          
           
 WHERE           
  ZM.AscStatementData_StatementProcessId = @pSettlementProcessId          
 --ORDER BY          
 -- ZM.AscStatementData_Year,ZM.AscStatementData_Month    
          
END          
          
------- 7. Calculation of Total Demand          
ELSE IF (@pStepId = 7)          
BEGIN          
 SELECT           
  ROW_NUMBER() OVER (ORDER BY MCH.BmeStatementData_Year,MCH.BmeStatementData_Month,MCH.BmeStatementData_Day,MCH.BmeStatementData_Hour,MCH.BmeStatementData_PartyRegisteration_Id) AS [Sr]          
  ,BmeStatementData_Month AS [month]          
  ,BmeStatementData_Day AS [Day]          
  ,BmeStatementData_Hour -1 AS [Hour]          
  ,BmeStatementData_CongestedZone AS [Congested Zone]          
      ,--GM.AscStatementData_CongestedZone AS [Congested Zone]          
    (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=MCH.BmeStatementData_CongestedZoneID) AS [Congested Zone]          
  ,MCH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]          
  ,mch.BmeStatementData_PartyName AS [MP Name]          
  ,MCH.BmeStatementData_PartyCategory_Code AS [MP Category]    
  ,Format(MCH.BmeStatementData_ActualEnergy,'N') AS [Act_E_ASC (kWh)]           
  --,Format(MCH.BmeStatementData_ES,'N') AS [ES_ASC (kWh)]          
  ,Format(MCH.BmeStatementData_EnergySuppliedActual,'N') AS [ES_ASC (kWh)]          
  ,Format(MCH.BmeStatementData_EnergyTraded,'N') AS [Energy Traded (kWh)]      
    
  --,MCH.BmeStatementData_EnergySuppliedActual AS [Act_E_ASC (kWh)]           
  --,MCH.BmeStatementData_ES AS [ES_ASC (kWh)]          
  --,MCH.BmeStatementData_EnergyTraded AS [Energy Traded (kWh)]          
 FROM           
  BmeStatementDataMpCategoryHourly_SettlementProcess MCH          
           
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
 ,--zm.AscStatementData_CongestedZone AS [Congested Zone]          
 (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=ZM.AscStatementData_CongestedZoneID) AS [Congested Zone]    
 ,Format(ZM.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC) (PKR)]          
 ,Format(ZM.AscStatementData_IG_AC,'N') AS [Increased Generation (PKR)]          
 ,Format(ZM.AscStatementData_RG_AC,'N') AS [Reduced Generation (PKR)]          
 ,Format(ZM.AscStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
 ,Format(ZM.AscStatementData_GBS_BSC,'N') AS [Black Start (PKR)]          
 ,Format(ZM.AscStatementData_TAC,'N') AS [Total Amount of Compensation (TAC) (PKR)]          
 ,Format(ZM.AscStatementData_TD,'N') AS [Total Demand (TD) (kWh)]       
    
  --,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
  --,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]          
  --,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]          
  --,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,ZM.AscStatementData_GBS_BSC [Black Start (PKR)]          
  --,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]          
  --,ZM.AscStatementData_TD AS [Total Demand (TD) (kWh)]          
 FROM           
  AscStatementDataZoneMonthly_SettlementProcess ZM          
            
           
 WHERE           
  ZM.AscStatementData_StatementProcessId = @pSettlementProcessId          
 --ORDER BY          
 -- ZM.AscStatementData_Year,ZM.AscStatementData_Month;          
END          
          
-------- 9. Category/Zone wise aggregated Receivables          
          
ELSE IF(@pStepId = 9)          
BEGIN          
 SELECT          
 ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Year,CM.BmeStatementData_Month,CM.BmeStatementData_PartyRegisteration_Id) AS [Sr]          
 ,CM.BmeStatementData_Month AS [month]          
 ,--CM.BmeStatementData_CongestedZone AS [Congested Zone]          
 (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=CM.BmeStatementData_CongestedZoneID) AS [Congested Zone]          
 ,CM.BmeStatementData_PartyRegisteration_Id AS [MP_ID]          
 ,cm.BmeStatementData_PartyName AS [MP Name]          
 ,CM.BmeStatementData_PartyCategory_Code AS [MP Category]    
 ,Format(CM.BmeStatementData_MRC,'N') AS [Must Run Compensation (MRC) (PKR)]          
 ,Format(CM.BmeStatementData_IG_AC,'N') AS [Increased Generation (PKR)]          
 ,Format(CM.BmeStatementData_RG_AC,'N') AS [Reduced Generation (PKR)]          
 ,Format(CM.BmeStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
 ,Format(CM.BmeStatementData_GBS_BSC,'N') AS [Black Start (PKR)]    
    
  --,CM.BmeStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
  --,CM.BmeStatementData_IG_AC AS [Increased Generation (PKR)]          
  --,CM.BmeStatementData_RG_AC AS [Reduced Generation (PKR)]          
  --,CM.BmeStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,CM.BmeStatementData_GBS_BSC AS [Black Start (PKR)]          
 FROM           
  BmeStatementDataMpCategoryMonthly_SettlementProcess CM          
           
  WHERE           
   CM.BmeStatementData_StatementProcessId = @BmeStatementProcessId          
 --ORDER BY           
 -- CM.BmeStatementData_Year,CM.BmeStatementData_Month,MP_ID          
END          
          
----------- 10.  Receivable determination of MP          
ELSE IF(@pStepId = 10)          
BEGIN          
with cte_summations as (          
 SELECT          
  CH.BmeStatementData_Month           
  ,CH.BmeStatementData_Day           
  ,CH.BmeStatementData_Hour    
  --,Format((SUM(CH.BmeStatementData_MRC)),'N') AS [BmeStatementData_MRC]          
  --,Format((SUM(CH.BmeStatementData_IG_AC)),'N') AS [BmeStatementData_IG_AC]          
  --,Format((SUM(CH.BmeStatementData_RG_AC)),'N') AS [BmeStatementData_RG_AC]    
    
  ,SUM(CH.BmeStatementData_MRC ) as BmeStatementData_MRC          
  ,SUM(CH.BmeStatementData_IG_AC)  as BmeStatementData_IG_AC          
  ,SUM(CH.BmeStatementData_RG_AC ) as BmeStatementData_RG_AC          
  FROM           
  BmeStatementDataMpCategoryHourly_SettlementProcess  CH           
 WHERE CH.BmeStatementData_StatementProcessId = @BmeStatementProcessId          
 AND CH.BmeStatementData_PartyType_Code = 'MP'          
 GROUP by           
  CH.BmeStatementData_Month           
  ,CH.BmeStatementData_Day           
  ,CH.BmeStatementData_Hour          
)          
     
 SELECT          
  ROW_NUMBER() OVER (ORDER BY CH.BmeStatementData_Year,CH.BmeStatementData_Month,CH.BmeStatementData_Day,CH.BmeStatementData_Hour,CH.BmeStatementData_PartyRegisteration_Id) AS [Sr]          
  ,CH.BmeStatementData_Month AS [Month]          
  ,CH.BmeStatementData_Day AS [Day]          
  ,CH.BmeStatementData_Hour -1 AS [Hour]          
  ,--CH.BmeStatementData_CongestedZone AS [Congested Zone]          
  (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=ch.BmeStatementData_CongestedZoneID) AS [Congested Zone]          
  ,CH.BmeStatementData_PartyRegisteration_Id AS [MP_ID]          
  ,CH.BmeStatementData_PartyName AS [MP Name]          
  ,CH.BmeStatementData_PartyCategory_Code AS [MP Category]          
  , case WHEN CH.BmeStatementData_PartyRegisteration_Id=1 then  Format(cte.BmeStatementData_MRC,'N')  else null end  AS [Must Run Compensation (MRC) (PKR)]          
  , case WHEN CH.BmeStatementData_PartyRegisteration_Id=1 then Format(cte.BmeStatementData_IG_AC,'N') else null end AS [Increased Generation (PKR)]          
  , case WHEN CH.BmeStatementData_PartyRegisteration_Id=1 then Format(cte.BmeStatementData_RG_AC,'N') else null end AS [Reduced Generation (PKR)]    
  ,Format(CH.BmeStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
  ,Format(CH.BmeStatementData_GBS_BSC,'N') AS [Black Start (PKR)]          
  ,Format(CH.BmeStatementData_TC,'N') AS [Total Cost (PKR)]     
    
  --,CH.BmeStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,CH.BmeStatementData_GBS_BSC AS [Black Start (PKR)]          
  --,CH.BmeStatementData_TC AS [Total Cost (PKR)]          
 FROM           
  BmeStatementDataMpCategoryHourly_SettlementProcess  CH          
  JOIN cte_summations cte on cte.BmeStatementData_Day=CH.BmeStatementData_Day AND          
  cte.BmeStatementData_Month=CH.BmeStatementData_Month and cte.BmeStatementData_Hour = CH.BmeStatementData_Hour          
           
 WHERE CH.BmeStatementData_StatementProcessId = @BmeStatementProcessId          
 AND CH.BmeStatementData_PartyType_Code = 'MP';          
END          
          
----- 11. Aggregate Determined Receivables          
ELSE IF(@pStepId = 11)          
BEGIN          
 SELECT          
  ROW_NUMBER() OVER (ORDER BY CM.BmeStatementData_Year,CM.BmeStatementData_Month,CM.BmeStatementData_PartyRegisteration_Id) AS [Sr]          
  ,CM.BmeStatementData_Month AS [Month]          
  ,--CM.BmeStatementData_CongestedZone AS [Congested Zone]          
  (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=CM.BmeStatementData_CongestedZoneID) AS [Congested Zone]          
  ,CM.BmeStatementData_PartyRegisteration_Id AS [MP_ID]          
  ,cm.BmeStatementData_PartyName AS [MP Name]          
  ,CM.BmeStatementData_PartyCategory_Code AS [MP Category]    
,Format(CM.BmeStatementData_MRC,'N') AS [Must Run Compensation (MRC) (PKR)]          
,Format(CM.BmeStatementData_IG_AC,'N') AS [Increased Generation (PKR)]          
,Format(CM.BmeStatementData_RG_AC,'N') AS [Reduced Generation (PKR)]          
,Format(CM.BmeStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
,Format(CM.BmeStatementData_GBS_BSC,'N') AS [Black Start (PKR)]    
    
  --,CM.BmeStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
  --,CM.BmeStatementData_IG_AC AS [Increased Generation (PKR)]          
  --,CM.BmeStatementData_RG_AC AS [Reduced Generation (PKR)]          
  --,CM.BmeStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,CM.BmeStatementData_GBS_BSC AS [Black Start (PKR)]          
 FROM           
  BmeStatementDataMpCategoryMonthly_SettlementProcess  CM          
           
 WHERE CM.BmeStatementData_StatementProcessId = @BmeStatementProcessId          
 --ORDER BY           
 -- CM.BmeStatementData_Year,CM.BmeStatementData_Month,MP_ID          
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
  ,--MZM.AscStatementData_CongestedZone AS [Congested Zone]          
  (select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=MZM.AscStatementData_CongestedZoneID) AS [Congested Zone]    
    
,Format(MZM.AscStatementData_MRC  ,'N') AS [Must Run Compensation (MRC) (PKR)]        
,Format(MZM.AscStatementData_IG_AC  ,'N') AS [Increased Generation (PKR)]        
,Format(MZM.AscStatementData_RG_AC  ,'N') AS [Reduced Generation (PKR)]        
,Format(MZM.AscStatementData_GS_SC  ,'N') AS [Startup Cost (PKR)]        
,Format(MZM.AscStatementData_GBS_BSC ,'N') AS [Black Start (PKR)]        
,Format(MZM.AscStatementData_PAYABLE  ,'N') AS [Payable (PKR)]        
,Format(MZM.AscStatementData_RECEIVABLE  ,'N') AS [Receivable (PKR)]   
  
  --,MZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
  --,MZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]          
  --,MZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]          
  --,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]          
  ----,MZM.AscStatementData_SC_BSC AS [Black Start (PKR)]          
  --,MZM.AscStatementData_GBS_BSC [Black Start (PKR)]          
  --,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]          
  --,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]          
            
        /*,MZM.AscStatementData_TP_SOLR AS [Adjusted Payable (PKR)]*/          
 INTO #temp          
 FROM          
  AscStatementDataMpZoneMonthly_SettlementProcess MZM          
           
 WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId          
 --ORDER BY           
 -- MZM.AscStatementData_Year,MZM.AscStatementData_Month,MP_ID          
          
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
 SELECT [Sr] , case WHEN [Month]=0 THEN NULL else [Month] end as [Month] ,[MP_ID],[MP Name],[Congested Zone] ,[Must Run Compensation (MRC) (PKR)], [Increased Generation (PKR)], [Reduced Generation (PKR)],[Startup Cost (PKR)], [Black Start (PKR)], [Payabl

e (PKR)],[Receivable (PKR)]          
 FROM #temp order by  case when [Sr] is null then 1 else 0 end, [SR]          
;          
          
END          
          
------ 13. Calculation for the adjustment of Power Pool / Legacy Generation 21          
ELSE IF(@pStepId = 13)          
BEGIN          
 SELECT           
  ROW_NUMBER() OVER (ORDER BY ZM.AscStatementData_Year,ZM.AscStatementData_Month) AS [Sr]          
  ,zm.AscStatementData_Month as [Month]          
  --,zm.AscStatementData_CongestedZone AS [Congested Zone]          
  ,(select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=zm.AscStatementData_CongestedZoneID) AS [Congested Zone]   
,Format(ZM.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC) (PKR)]          
,Format(ZM.AscStatementData_IG_AC,'N') AS [Increased Generation (PKR)]          
,Format(ZM.AscStatementData_RG_AC,'N') AS [Reduced Generation (PKR)]          
,Format(ZM.AscStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
,Format(ZM.AscStatementData_GBS_BSC,'N') AS [Black Start (PKR)]          
,Format(ZM.AscStatementData_TAC,'N') AS [Total Amount of Compensation (TAC) (PKR)]          
,Format(ZM.AscStatementData_TD,'N') AS [Total Demand (TD) (kWh)]          
,Format(ZM.AscStatementData_ES_BS,'N') AS [Energy Supplied to BS (kWh)]          
,Format(ZM.AscStatementData_KE_ES,'N') AS [Energy Supplied to KE (kWh)]          
,Format(ZM.AscStatementData_TP,'N') AS [Total Payable (PKR)]          
  
  --,ZM.AscStatementData_MRC AS [Must Run Compensation (MRC) (PKR)]          
  --,ZM.AscStatementData_IG_AC AS [Increased Generation (PKR)]          
  --,ZM.AscStatementData_RG_AC AS [Reduced Generation (PKR)]          
  --,ZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,ZM.AscStatementData_GBS_BSC [Black Start (PKR)]          
  --,ZM.AscStatementData_TAC AS [Total Amount of Compensation (TAC) (PKR)]          
  --,ZM.AscStatementData_TD AS [Total Demand (TD) (kWh)]          
  --      ,ZM.AscStatementData_ES_BS AS  [Energy Supplied to BS (kWh)]          
  --,ZM.AscStatementData_KE_ES AS  [Energy Supplied to KE (kWh)]          
  --,ZM.AscStatementData_TP  [Total Payable (PKR)]          
 FROM           
  AscStatementDataZoneMonthly_SettlementProcess ZM          
            
           
 WHERE           
  ZM.AscStatementData_StatementProcessId = @pSettlementProcessId          
 --ORDER BY          
 -- ZM.AscStatementData_Year,ZM.AscStatementData_Month;          
END          
          
--14. Adjustment of Powerpool/Legacy generation (MP Zone-wise)          
ELSE IF(@pStepId = 14)          
BEGIN          
 DROP TABLE IF EXISTS #tempPowerPool2;          
          
 with cte_ascSummation as (           
 SELECT           
  MZM.AscStatementData_Year          
  ,MZM.AscStatementData_Month  
,SUM(MZM.AscStatementData_MRC) AS [AscStatementData_MRC]          
,SUM(MZM.AscStatementData_IG_AC) AS [AscStatementData_IG_AC]     
,SUM(MZM.AscStatementData_RG_AC) AS [AscStatementData_RG_AC]    
  
  --,SUM(MZM.AscStatementData_MRC) AS AscStatementData_MRC          
  --,SUM(MZM.AscStatementData_IG_AC) as AscStatementData_IG_AC          
  --,SUM(MZM.AscStatementData_RG_AC) as AscStatementData_RG_AC          
 FROM          
  [dbo].AscStatementDataMpZoneMonthly_SettlementProcess  MZM           
 WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId          
 GROUP BY MZM.AscStatementData_Year, MZM.AscStatementData_Month          
)          
 SELECT           
  ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Year,MZM.AscStatementData_Month,MZM.AscStatementData_PartyRegisteration_Id) AS [Sr]          
  ,MZM.AscStatementData_Month AS [month]          
  ,MZM.AscStatementData_PartyRegisteration_Id AS [MP ID]          
  ,MZM.AscStatementData_PartyName AS [MP Name]          
 -- ,MZM.AscStatementData_CongestedZone AS [Congested Zone]          
  ,(select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=Mzm.AscStatementData_CongestedZoneID) AS [Congested Zone]          
  ,case when MZM.AscStatementData_PartyRegisteration_Id=1 then FORMAT(CTE.AscStatementData_MRC,'N') else null end as [Must Run Compensation (MRC) (PKR)]                         
  ,case when MZM.AscStatementData_PartyRegisteration_Id=1 then FORMAT(CTE.AscStatementData_IG_AC,'N') else null end as [Increased Generation (PKR)]          
  ,case when MZM.AscStatementData_PartyRegisteration_Id=1 then FORMAT(CTE.AscStatementData_RG_AC,'N') else null end as [Reduced Generation (PKR)]        
,Format(MZM.AscStatementData_GS_SC,'N') AS [Startup Cost (PKR)]          
,Format(MZM.AscStatementData_GBS_BSC,'N') AS [Black Start (PKR)]          
,Format(mzm.AscStatementData_ES,'N') AS [Energy Supplied (kWh)]          
,Format(mzm.AscStatementData_TP_SOLR,'N') AS [Legacy Generation Adjustment (PKR)]          
,Format(MZM.AscStatementData_PAYABLE,'N') AS [Payable (PKR)]          
,Format(MZM.AscStatementData_RECEIVABLE,'N') AS [Receivable (PKR)]  
  
  --,MZM.AscStatementData_GS_SC AS [Startup Cost (PKR)]          
  --,MZM.AscStatementData_GBS_BSC [Black Start (PKR)]          
  --,mzm.AscStatementData_ES AS [Energy Supplied (kWh)]          
  --,mzm.AscStatementData_TP_SOLR AS [Legacy Generation Adjustment (PKR)]          
  --,MZM.AscStatementData_PAYABLE AS [Payable (PKR)]          
  --,MZM.AscStatementData_RECEIVABLE AS [Receivable (PKR)]          
            
 INTO #tempPowerPool2          
 FROM          
  [dbo].AscStatementDataMpZoneMonthly_SettlementProcess  MZM          
 join cte_ascSummation CTE on CTE.AscStatementData_Year=MZM.AscStatementData_YEAR          
 and CTE.AscStatementData_Month=MZM.AscStatementData_Month          
 WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId;          
          
  INSERT INTO #tempPowerPool2          
  ([month]           
  ,[MP Name]          
  ,[Payable (PKR)]          
  ,[Receivable (PKR)]          
  )          
 VALUES          
 (          
  ''          
  ,'Total'          
  ,(SELECT ISNULL(SUM([Payable (PKR)]),0) FROM #tempPowerPool2)          
  ,(SELECT ISNULL(SUM([Receivable (PKR)]),0) FROM #tempPowerPool2)          
 )          
          
 SELECT [Sr] , case WHEN [Month]=0 THEN NULL else [Month] end as [Month],[MP ID] ,[MP Name],[Congested Zone] ,[Must Run Compensation (MRC) (PKR)], [Increased Generation (PKR)], [Reduced Generation (PKR)],[Startup Cost (PKR)], [Black Start (PKR)] ,[Energy
 
Supplied (kWh)],[Legacy Generation Adjustment (PKR)], [Payable (PKR)],[Receivable (PKR)]          
 FROM #tempPowerPool2 order by case when [Sr] is null then 1 else 0 end,[SR];          
END          
          
--- 15. MP wise ASC Payable and Receiveable with Settlement of Legacy           
ELSE IF(@pStepId = 15)          
BEGIN          

 SELECT  BmeStatementData_Year
		,BmeStatementData_Month
         ,BmeStatementData_PartyRegisteration_Id
		,BmeStatementData_CongestedZoneID--, BmeStatementData_ES
		,SUM(BmeStatementData_EnergySuppliedActual)  as BmeStatementData_EnergySuppliedActual
INTO #EnergySuppliedActual
 FROM BmeStatementDataMpCategoryHourly_SettlementProcess 
 WHERE BmeStatementData_StatementProcessId=@BmeStatementProcessId
 GROUP BY 
  BmeStatementData_Year
		,BmeStatementData_Month
         ,BmeStatementData_PartyRegisteration_Id
		,BmeStatementData_CongestedZoneID--, BmeStatementData_ES



 /**taski id 3933 * date 27-sep-2023*/
 SELECT BmeStatementData_BuyerPartyRegisteration_Id, SUM(BmeStatementData_EnergyTradedBought) AS BmeStatementData_EnergyTradedBought
 INTO #BmeStatementData_EnergyTradedBought_MPWise
FROM BmeStatementDataMpContractHourly_SettlementProcess    
WHERE BmeStatementData_StatementProcessId=@BmeStatementProcessId
AND BmeStatementData_SellerPartyRegisteration_Id=1 -- only for leagacy
GROUP BY BmeStatementData_BuyerPartyRegisteration_Id;

	with cte_ascSummation as (	
	SELECT 
		MZM.AscStatementData_Year
		,MZM.AscStatementData_Month 
		,SUM(MZM.AscStatementData_MRC) AS AscStatementData_MRC
		,SUM(MZM.AscStatementData_IG_AC) as AscStatementData_IG_AC
		,SUM(MZM.AscStatementData_RG_AC) as AscStatementData_RG_AC
	FROM
		[dbo].AscStatementDataMpZoneMonthly_SettlementProcess  MZM	
	WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	GROUP BY MZM.AscStatementData_Year, MZM.AscStatementData_Month
)

select 
ROW_NUMBER() OVER(Order by AscStatementData_PartyRegisteration_Id) as [Sr],
MZM.AscStatementData_Month as [Month],
MZM.AscStatementData_PartyRegisteration_Id as [Party ID],
MZM.AscStatementData_PartyName as [Party Name],
MZM.AscStatementData_CongestedZone as [Congested Zone],
case when MZM.AscStatementData_PartyRegisteration_Id=1 then Format(CTE.AscStatementData_MRC,'N')  else null end as [Must Run Compensation (PKR)]
,case when MZM.AscStatementData_PartyRegisteration_Id=1 then Format(CTE.AscStatementData_IG_AC,'N')  else null end as [Increased Generation Compensation (PKR)]
,case when MZM.AscStatementData_PartyRegisteration_Id=1 then Format(CTE.AscStatementData_RG_AC,'N')  else null end as [Reduced Generation Compensation (PKR)]
,Format(AscStatementData_GS_SC,'N')  as [Startup cost (PKR)]
,Format(MZM.AscStatementData_GBS_BSC,'N')  as [Black start charges (PKR)],
--Format(MZM.AscStatementData_ES,'N')  as [Energy Withdrawal with Transmission Loss (kWh)],
Format(ESA.BmeStatementData_EnergySuppliedActual,'N')  as [Energy Withdrawal with Transmission Loss (kWh)],
Format(MZM.AscStatementData_PAYABLE,'N')  as [Payable (PKR)],
Format(MZM.AscStatementData_RECEIVABLE,'N')  as [Receivable (PKR)],
--Case when AscStatementData_PartyRegisteration_Id=1 then null else Format(AscStatementData_ES,'N')  end as [Energy Contracted with Legacy Generators (kWh)],
Case when AscStatementData_PartyRegisteration_Id=1 then null else Format(MPWISE.BmeStatementData_EnergyTradedBought,'N')  end as [Energy Contracted with Legacy Generators (kWh)],

--Format(AscStatementData_TP_SOLR,'N')  as [Share in Payable to Legacy Generators (PKR)],
Format(AscStatementData_SOLR_ETB_Legacy,'N')  as [Share in Payable to Legacy Generators (PKR)],

--Case when AscStatementData_PartyRegisteration_Id=1 then null else Format( ISNULL(MZM.AscStatementData_TP_SOLR,0)-ISNULL(MZM.AscStatementData_RECEIVABLE,0),'N')  
--end as [Share in Receivables from Legacy Generators (PKR)] ,

Case when AscStatementData_PartyRegisteration_Id=1 then null 
else AscStatementData_LegacyShareInReceiveable
end as [Share in Receivables from Legacy Generators (PKR)] ,




Case when AscStatementData_PartyRegisteration_Id=1 then NULL
--else Format( ISNULL(MZM.AscStatementData_PAYABLE,0)+ISNULL(MZM.AscStatementData_TP_SOLR,0),'N') 
ELSE Format(AscStatementData_SOLR_ETB_Legacy,'N') 
end as [Total Payable (PKR)],

Case when AscStatementData_PartyRegisteration_Id=1 then null 
--else Format( ISNULL(MZM.AscStatementData_RECEIVABLE,0)+ISNULL(MZM.AscStatementData_TP_SOLR,0)-ISNULL(MZM.AscStatementData_RECEIVABLE,0),'N') 
ELSE ISNULL(MZM.AscStatementData_RECEIVABLE,0)+ISNULL(AscStatementData_LegacyShareInReceiveable,0)
end  as [Total Receivable (PKR)]

from [dbo].AscStatementDataMpZoneMonthly_SettlementProcess MZM
	join cte_ascSummation CTE on CTE.AscStatementData_Year=MZM.AscStatementData_YEAR
	and CTE.AscStatementData_Month=MZM.AscStatementData_Month
	JOIN #EnergySuppliedActual ESA ON ESA.BmeStatementData_Year=MZM.AscStatementData_Year
	AND ESA.BmeStatementData_Month=MZM.AscStatementData_Month
	AND ESA.BmeStatementData_PartyRegisteration_Id=MZM.AscStatementData_PartyRegisteration_Id
	AND ESA.BmeStatementData_CongestedZoneID=MZM.AscStatementData_CongestedZoneID
	LEFT JOIN #BmeStatementData_EnergyTradedBought_MPWise MPWISE ON MZM.AscStatementData_PartyRegisteration_Id=MPWISE.BmeStatementData_BuyerPartyRegisteration_Id 
where MZM.AscStatementData_StatementProcessId=@pSettlementProcessId
order by AscStatementData_PartyRegisteration_Id


END          
          
-- 16. Calculation of ESS Adjustment (For ESS Only)          
          
ELSE IF(@pStepId = 16 and @vSrProcessDef_ID =8)          
BEGIN          
 Declare @vPredecessorId as decimal(18,0)          
          
select @vPredecessorId=[dbo].[GetESSAdjustmentPredecessorStatementId](@pSettlementProcessId);          
          
SELECT           
  ROW_NUMBER() OVER (ORDER BY MZM.AscStatementData_Year,MZM.AscStatementData_Month,MZM.AscStatementData_PartyRegisteration_Id) AS [Sr]          
  ,MZM.AscStatementData_Month AS [Month]          
  ,MZM.AscStatementData_PartyRegisteration_Id AS [MP ID]          
  ,MZM.AscStatementData_PartyName AS [MP Name]  
,Format(MZM.AscStatementData_MRC  ,'N') AS [Must Run Compensation (MRC) (PKR)]          
,Format(MZM.AscStatementData_IG_AC  ,'N') AS [Increased Generation (PKR)]          
,Format(MZM.AscStatementData_RG_AC  ,'N') AS [Reduced Generation (PKR)]          
,Format(MZM.AscStatementData_GS_SC  ,'N') AS [Startup Cost (PKR)]          
,Format(MZM.AscStatementData_SC_BSC  ,'N') AS [Black Start (PKR)]          
,Format(MZM_Previous.AscStatementData_RECEIVABLE  ,'N') AS [Previous Month Receivable (PKR)]          
,Format(MZM_Previous.AscStatementData_PAYABLE  ,'N') AS [Previous Month Payable (PKR)]          
,Format(MZM.AscStatementData_RECEIVABLE  ,'N') AS [Receivable (PKR)]          
,Format(MZM.AscStatementData_PAYABLE  ,'N') AS [Payable (PKR)]          
,Format(MZM.AscStatementData_AdjustmentRECEIVABLE  ,'N') AS [Adjustment Receivable (PKR)]          
,Format(MZM.AscStatementData_AdjustmentPAYABLE  ,'N') AS [Adjustment Payable (PKR)]          
  
 
 INTO #tempStep22          
 FROM          
  [dbo].[AscStatementDataMpMonthly_SettlementProcess] MZM          
   Join  [AscStatementDataMpMonthly_SettlementProcess] MZM_Previous on           
   MZM.AscStatementData_PartyRegisteration_Id=MZM_Previous.AscStatementData_PartyRegisteration_Id          
           
 WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId          
 and MZM_Previous.AscStatementData_StatementProcessId=@vPredecessorId          
 --and MZM.AscStatementData_PartyRegisteration_Id <> 1115         --ORDER BY           
 -- MZM.AscStatementData_Month,MZM.AscStatementData_Year          
          
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
 [Sr] ,case WHEN [Month]=0 THEN NULL else [Month] end as [Month] ,[MP Name] ,[MP ID], [Must Run Compensation (MRC) (PKR)],[Increased Generation (PKR)],[Reduced Generation (PKR)],[Startup Cost (PKR)], [Black Start (PKR)], [Payable (PKR)],[Receivable (PKR)]
,[Previous Month Payable (PKR)] as ['+@vPredecessorMonthName+' Payable (PKR)],[Previous Month Receivable (PKR)] as ['+@vPredecessorMonthName+' Receivable (PKR)],[Adjustment Payable (PKR)],[Adjustment Receivable (PKR)] from #tempStep22 order by case when [
Sr] is null then 1 else 0 end, [Sr]          
'          
exec (@query);          
           
END          
          
          
ELSE if(          
(@pStepId=16 AND @vSrProcessDef_ID IN (2,5))  -- For PSS|FSS Post validation          
OR (@pStepId=17 AND @vSrProcessDef_ID =8 )          
)  -- FOR ESS Post Validation.          
BEGIN          
 EXECUTE [ASC_PostValidationReport] @pSettlementProcessId          
          
END          
          
          
          
END 
