/****** Object:  Procedure [dbo].[BMC_StepsOutputViews]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================      
-- Author: Alina Javed      
-- CREATE date: 28 December 2022      
-- ALTER date:          
-- Description:                     
--==========================================================================================      
    -- dbo.BMC_StepsOutputViews  324,13  
CREATE PROCEDURE dbo.BMC_StepsOutputViews (      
@pSettlementProcessId DECIMAL(18, 0),      
@pStepId DECIMAL(4, 1))
AS      
BEGIN      
    BEGIN TRY 

DECLARE @vSrProcessDef_Id DECIMAL(18,0);

	SELECT 
		@vSrProcessDef_Id = msp.SrProcessDef_ID 
	FROM MtStatementProcess msp 
	WHERE msp.MtStatementProcess_ID = @pSettlementProcessId
IF EXISTS (SELECT  
                TOP 1 1  
            FROM MtStatementProcess msp  
            WHERE msp.MtStatementProcess_ID = @pSettlementProcessId  
            AND msp.MtStatementProcess_IsDeleted = 0 and SrProcessDef_ID IN (16,22))  
  
   BEGIN  
  
   DECLARE @vBMCFinalStatementId DECIMAL(18,0); 
   SELECT
		@vBMCFinalStatementId = [dbo].[GetBMCStatementProcessID](@pSettlementProcessId);

  
  
   IF (@pStepId = 1)     
        BEGIN      
          
  select   
    ROW_NUMBER() over (order by PR.MtPartyRegisteration_Id) as [Sr],      
 PR.MtPartyRegisteration_Name as [MP Name],  
 CONVERT(INT,PR.MtPartyRegisteration_Id) as [MP ID],    
 FORMAT(PMD.BMCPYSSMPData_RequiredSecurityCover,'N') as [Required Security Cover (PKR)],  
 FORMAT(PMD.BMCPYSSMPData_SubmittedSecurityCover,'N') as [Submitted Security Cover (PKR)],  
 ABS(MD.BMCMPData_CapacityBalance) as [Capacity Requirement of Market Participants (MW)],
 ABS(MD.BMCMPData_CapacityPurchased) as [Capacity Preliminary Allocated to Market Participant (MW)],
 ABS(pmd.BMCPYSSMPData_PreliminaryCapacityAllocatedSC) as [Capacity Preliminary Allocation after Security Cover (MW)],
 FORMAT(ABS(PMD.BMCPYSSMPData_CapacityAvailableRevised),'N') as [Capacity Available (MW)]  
  from   
 MtPartyRegisteration PR  
 inner join BMCPYSSMPData PMD on PMD.MtPartyRegisteration_Id=PR.MtPartyRegisteration_Id   
 inner join BMCMPData MD on MD.MtPartyRegisteration_Id=PR.MtPartyRegisteration_Id      
   where  
  ISNULL(PR.isDeleted,0)=0      
  AND PMD.MtStatementProcess_ID=@pSettlementProcessId   
  AND MD.MtStatementProcess_ID= @vBMCFinalStatementId  
  
 ORDER BY PR.MtPartyRegisteration_Id ASC  
  
-----1.1----  
 DECLARE @vCapacityBalanceNegative DECIMAL(38, 13);
    SELECT
        @vCapacityBalanceNegative = ABS(SUM(MP.BMCMPData_CapacityBalance))
    FROM BMCPYSSMPData RMP
    INNER JOIN BMCMPData MP
        ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
    INNER JOIN BMCVariablesData VD
        ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
    WHERE RMP.MtStatementProcess_ID = @pSettlementProcessId
    AND MP.MtStatementProcess_ID = @vBMCFinalStatementId
    AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
    AND VD.BMCVariablesData_CapacityBalancePositiveSum < VD.BMCVariablesData_CapacityBalanceNegativeSum
    AND MP.BMCMPData_CapacityBalance < 0
    AND RMP.BMCPYSSMPData_RequiredSecurityCover <= RMP.BMCPYSSMPData_SubmittedSecurityCover;
SELECT
    ABS(SUM(ISNULL(PM.BMCPYSSMPData_CapacityAvailableRevised, 0))) AS [Additional Capacity Available (MW)]
   ,@vCapacityBalanceNegative AS [Cumulative Capacity Requirement of MPs with Complete Security Cover]
FROM BMCPYSSMPData PM  
 where   
  PM.MtStatementProcess_ID=@pSettlementProcessId;  
        END  
------------------------
  if (@pStepId = 2)  
  BEGIN  
  declare @vset varchar(max);
  set @vset=[dbo].[GetBMCStatementProcessID](@pSettlementProcessId);
  SELECT ROW_NUMBER() over (order by PR.MtPartyRegisteration_Id) as [Sr],      
  PR.MtPartyRegisteration_Name as [MP Name],  
  PR.MtPartyRegisteration_Id as [MP ID],  
  ISNULL(md.BMCMPData_CapacitySold,0)  as [Preliminary Capacity Sold by Market Participant (MW)],
  ISNULL(PMD.BMCPYSSMPData_CapacitySoldRevised,0) AS [Revised Capacity Sold by Market Participant (MW)],  
  ABS(pmd.BMCPYSSMPData_PreliminaryCapacityAllocatedSC) as [Capacity Preliminary Allocation after Security Cover (MW)],
  ABS(ISNULL(PMD.BMCPYSSMPData_CapacityPurchasedRevised,0)) as [Revised Capacity Purchased by Market Participant (MW)]   
    from   
     MtPartyRegisteration PR  
     inner join BMCPYSSMPData PMD on PMD.MtPartyRegisteration_Id=PR.MtPartyRegisteration_Id 
	 inner join BMCMPData MD on MD.MtPartyRegisteration_Id=PMD.MtPartyRegisteration_Id
   where  
  ISNULL(PR.isDeleted,0)=0      
  AND PMD.MtStatementProcess_ID=@pSettlementProcessId
  AND MD.MtStatementProcess_ID=@vset; 
  
END  
 ------------------ 
ELSE IF @pStepId = 3      
        BEGIN      
    SELECT  
    ROW_NUMBER() over (order by PR.MtPartyRegisteration_Id) as [Sr],      
 PR.MtPartyRegisteration_Name as [MP Name],  
 PR.MtPartyRegisteration_Id as [MP ID],  
  ABS(ISNULL(MPR.BMCPYSSMPData_CapacitySoldRevised,0)) as [Revised Capacity Sold by Market Participant (MW)],  
 ABS(ISNULL(MPR.BMCPYSSMPData_CapacityPurchasedRevised,0)) as [Revised Capacity Purchased by MP (MW)],   
 VD.BMCVariablesData_CapacityPrice as [Capacity Price (PKR/MW/year)],  
 ABS(ISNULL(MPR.BMCPYSSMPData_AmountPayableRevised,0)) as [Final Amount Payable by MP(PKR)],  
 ISNULL(MPR.BMCPYSSMPData_AmountReceivableRevised,0) as [Final Amount Receivable by MP (PKR)]   
  from   
 MtPartyRegisteration PR  
 inner join BMCPYSSMPData MPR on MPR.MtPartyRegisteration_Id=PR.MtPartyRegisteration_Id   
 inner join BMCMPData MP on MP.MtPartyRegisteration_Id=MPR.MtPartyRegisteration_Id   
 inner JOIN BMCVariablesData VD on vd.MtStatementProcess_ID=MP.MtStatementProcess_ID  
   where  
  ISNULL(PR.isDeleted,0)=0       
       AND MPR.MtStatementProcess_ID=@pSettlementProcessId    
      AND VD.MtStatementProcess_ID= @vBMCFinalStatementId  
  ORDER by 3;      
        END      
   END   
  
  ELSE  
   BEGIN  
 -------------       
   IF @pStepId = 2      
        BEGIN      
    select       
  ROW_NUMBER() over (order by MtGenerator_Name) as [Sr No.],      
  MtGenerationUnit.MtGenerationUnit_Id as [Generator Unit ID],      
  MtGenerator_Name as [Generator Name],       
  BMCAvailableCapacityGU_AvgCapacitySO as [Average Capacity During Critical Hours (kW)]      
 from       
  MtGenerator mtg inner join MtGenerationUnit on MtGenerationUnit.MtGenerator_Id=mtg.MtGenerator_Id      
  inner join [dbo].[BMCAvailableCapacityGU] on BMCAvailableCapacityGU.MtGenerationUnit_Id=MtGenerationUnit.MtGenerationUnit_Id      
        where ISNULL(mtg.isDeleted,0)=0      
  AND ISNULL(mtg.MtGenerator_IsDeleted,0)=0      
  and ISNULL(mtgenerationunit.isDeleted,0)=0      
  AND ISNULL(MtGenerationUnit.MtGenerationUnit_IsDeleted,0)=0      
  AND [dbo].[BMCAvailableCapacityGU].MtStatementProcess_ID=@pSettlementProcessId      
  ORDER by 3;      
        END      
   
   --------------------    
        ELSE IF (@pStepId in (4,5))      
        BEGIN      
        select       
  ROW_NUMBER() over (order by BAC.MtGenerator_Id) as [Sr No.],      
 -- GU.MtGenerationUnit_Id as [Generator Unit ID],  
  --MtGenerator_Name as [Generator Name],      
  BAC.MtGenerator_Id as [Generator ID],  
  (SELECT TOP 1 v.GenName FROM [vw_OnlyGenUnit] v WHERE v.GenId = BAC.MtGenerator_Id ) as [Generator Name],  
 -- GU.MtGenerator_Name AS [Generator Name],    
  BAC.BMCAvailableCapacityGen_AvailableCapacityAvg as [Average Capacity During Critical Hours (kW)],      
  BMCAvailableCapacityGen_AvailableCapacityKE as [KE Share for Each Generator (kW)],       
  BMCAvailableCapacityGen_AvailableCapacityAfterKE as [Average Capacity During Critical Hours After KE Share (kW)]      
 from     --[dbo].[BMCAvailableCapacityGU] GU   
    
   [dbo].[BMCAvailableCapacityGen] BAC    
   --JOIN [dbo].[vw_OnlyGenUnit] v ON BAC.MtGenerator_Id = v.GenId  
  
   --on BAC.MtGenerator_Id=GU.MtGenerator_Id    
    where       
        BAC.MtStatementProcess_ID= @pSettlementProcessId      
      -- AND GU.MtStatementProcess_ID=111  
         
order by BAC.MtGenerator_Id   
        END      
 --------------------     
  ELSE IF (@pStepId =6)      
         BEGIN      
      --------6.1     
     
--   SELECT  
   
--   mp.MtPartyRegisteration_Name AS [Party Name]  
--   ,CC.MtGenerator_Id AS [Generator Id]  
--   ,(SELECT TOP 1  
--   GU.GenName  
--  FROM vw_OnlyGenUnit GU  
--  WHERE GU.GenId = CC.MtGenerator_Id)  
-- AS [Generator Name]  
--   ,CC.BMCMPGenCreditedCapacity_CreditedCapacity  
--INTO #CreditedCapacity 
--FROM [dbo].[BMCMPGenCreditedCapacity] CC  
--JOIN MtPartyRegisteration mp  
-- ON CC.MtPartyRegisteration_Id = mp.MtPartyRegisteration_Id  
--WHERE CC.MtStatementProcess_ID = @pSettlementProcessId  
  
--SELECT DISTINCT [Party Name] into #PartyName FROM #CreditedCapacity  
  
  
--DECLARE @MPList varchar(MAX)  
  
--SELECT  @MPList = COALESCE(@MPList + ', ', '') +   
--   '['+CAST(t.[Party Name] AS varchar(250))+']'  
--FROM #PartyName t  
----SELECT @MPList  
  
  
  
  
  
--DECLARE @SqlStatement NVARCHAR(MAX);  
--SET @SqlStatement = N'  
--SELECT * FROM  
--(  
--SELECT * FROM #CreditedCapacity  
--)Tab1  
--PIVOT  
--(  
--SUM([BMCMPGenCreditedCapacity_CreditedCapacity]) FOR [Party Name] IN ('+@MPList+')  
--) AS Tab2    
--'  
  
--Execute (@SqlStatement)  
  
  
  DROP TABLE IF EXISTS #CreditedCapacity
DROP TABLE IF EXISTS #PartyName
DROP TABLE IF EXISTS #SumGenWise



SELECT  
   
   mp.MtPartyRegisteration_Name AS [Party Name]  
   ,CC.MtGenerator_Id AS [Generator Id]  
   ,(SELECT TOP 1  
   GU.GenName  
  FROM vw_OnlyGenUnit GU  
  WHERE GU.GenId = CC.MtGenerator_Id)  
 AS [Generator Name]  
   ,CC.BMCMPGenCreditedCapacity_CreditedCapacity  
INTO #CreditedCapacity 
FROM [dbo].[BMCMPGenCreditedCapacity] CC  
JOIN MtPartyRegisteration mp  
 ON CC.MtPartyRegisteration_Id = mp.MtPartyRegisteration_Id  
WHERE CC.MtStatementProcess_ID = @pSettlementProcessId;  
  
SELECT DISTINCT [Party Name] into #PartyName FROM #CreditedCapacity 


SELECT 
cc.[Generator Id],
cc.[Generator Name],
	SUM(cc.BMCMPGenCreditedCapacity_CreditedCapacity) AS SumCapacityGen 
INTO #SumGenWise
FROM 
	#CreditedCapacity cc 
GROUP BY 
	cc.[Generator Id],
	cc.[Generator Name];

  
  
DECLARE @MPList varchar(MAX),
@vMPNameConcat VARCHAR(MAX);
  
SELECT  @MPList = COALESCE(@MPList + ', ', '') +   
   '['+CAST(t.[Party Name] AS varchar(250))+']'  
FROM #PartyName t  
--SELECT @MPList  
  
  

  
        SET @vMPNameConcat = STUFF((SELECT distinct ',' + (Concat('SUM([',[Party Name],']) as [Credited Capacity (',[Party Name],') (MW)]')) 
            FROM #PartyName 
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
  
  
  
DECLARE @SqlStatement NVARCHAR(MAX);  
SET @SqlStatement = N'  
SELECT * into #GenWiseMPCap FROM  
(  
SELECT
		cc.[Generator Id], 
		cc.[Generator Name],
		cc.[Party Name],
		cc.BMCMPGenCreditedCapacity_CreditedCapacity,
		sgw.SumCapacityGen 
	FROM 
		#CreditedCapacity cc 
		inner join #SumGenWise sgw on  cc.[Generator Id] = sgw.[Generator Id])Tab1  
PIVOT  
(  
SUM([BMCMPGenCreditedCapacity_CreditedCapacity]) FOR [Party Name] IN ('+@MPList+')  
) AS Tab2   

select [Generator Name],  SumCapacityGen as [Total Capacity (MW)] , '+@vMPNameConcat+' from #GenWiseMPCap 
group by [Generator Name] ,SumCapacityGen

'  
  
Execute (@SqlStatement)  
  
  
  
  
  
 --   SELECT  
 -- ROW_NUMBER() OVER (ORDER BY MPR.MtPartyRegisteration_Id) AS [Serial No.]  
 --   ,MPR.MtPartyRegisteration_Id AS [MP ID]  
 --   ,MPR.MtPartyRegisteration_Name AS [MP Name]  
 --   ,mgu.MtGenerationUnit_SOUnitId AS [Generator SO ID]  
 --   ,mg.MtGenerator_Name AS [Generator Name]  
 --   ,bcg.BMCAvailableCapacityGen_AvailableCapacityAvg AS [Capacity Credited to MP (kW)]  
 --FROM MtGenerator mg  
 -- INNER JOIN MtPartyCategory mpc  
 --  ON mpc.MtPartyCategory_Id = mg.MtPartyCategory_Id  
 -- INNER JOIN MtPartyRegisteration MPR  
 --  ON MPR.MtPartyRegisteration_Id = mpc.MtPartyRegisteration_Id  
 -- INNER JOIN BMCAvailableCapacityGen bcg  
 --  ON bcg.MtGenerator_Id = mg.MtGenerator_Id  
 -- INNER JOIN MtGenerationUnit mgu  
 --  ON mg.MtGenerator_Id = mgu.MtGenerator_Id  
 --   where       
 --       bcg.MtStatementProcess_ID=@pSettlementProcessId  
 -- AND        
 --   ISNULL(mg.isDeleted,0)=0    
 --   AND ISNULL(mgu.isDeleted,0) = 0  
 --   AND ISNULL(MtGenerator_IsDeleted,0) = 0  
 --   AND ISNULL(mpc.isDeleted,0) = 0  
 --   AND ISNULL(mpr.isDeleted,0) = 0  
 --ORDER BY MPR.MtPartyRegisteration_Id, mgu.MtGenerationUnit_SOUnitId   
  ------6.2      
  select       
   ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Id as [MP ID], MPR.MtPartyRegisteration_Name as [MP Name],       
     bmd.BMCMPData_AllocatedCapacity as [Cumulative Capacity Credited To MP During Critical Hours (MW)]      
 from       
   MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
    where       
         bmd.MtStatementProcess_ID=@pSettlementProcessId;      
         
         END      
      
 ELSE IF (@pStepId =7)      
         BEGIN      
    select       
  DISTINCT BMCActualEnergyCriticalHourly_Month, BMCActualEnergyCriticalHourly_Day,BMCActualEnergyCriticalHourly_Hour      
  INTO #TStep7      
 FROM       
  BMCActualEnergyCriticalHourly baech       
 where baech.MtStatementProcess_ID= @pSettlementProcessId      
      
 select       
  ROW_NUMBER() OVER (ORDER BY  BMCActualEnergyCriticalHourly_Month, BMCActualEnergyCriticalHourly_Day,BMCActualEnergyCriticalHourly_Hour ,mpr.MtPartyRegisteration_Id) AS [Sr],      
  BMCActualEnergyCriticalHourly_Month as [Month],       
  BMCActualEnergyCriticalHourly_Day as [Day],      
  BMCActualEnergyCriticalHourly_Hour as [Hour],            
  mpr.MtPartyRegisteration_Name as [MP Name],    
  mpr.MtPartyRegisteration_Id as [MP ID],  
  BMCActualEnergyCriticalHourly_ActualEnergy as [Hourly Adjusted Energy During Critical Hours (Act_E) (kWh)]      
 from       
  BMCActualEnergyCriticalHourly baech      
  inner join MtPartyRegisteration mpr on mpr.MtPartyRegisteration_Id=baech.MtPartyRegisteration_Id      
    where       
         baech.MtStatementProcess_ID=@pSettlementProcessId;         
         END      
      
 ELSE IF (@pStepId =8)      
         BEGIN      
    select       
   ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],      
   MPR.MtPartyRegisteration_Id as [MP ID],       
   ISNULL(bmd.BMCMPData_CapacityRequirement,0) as [Capacity Requirement During Critical Hours(MW)]      
  from    MtPartyRegisteration MPR      
       inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
  where        
      bmd.MtStatementProcess_ID=@pSettlementProcessId            
      order by MPR.MtPartyRegisteration_Id; 
   END      
   ELSE IF (@pStepId =9)      
         BEGIN      
---------------9.1      
    select       
   ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],       
   MPR.MtPartyRegisteration_Id as [MP ID],       
   ISNULL(bmd.BMCMPData_AllocatedCapacity,0) as [Capacity Credited During Critical Hours(MW)],       
   ISNULL(bmd.BMCMPData_CapacityRequirement,0) as [Capacity Requirement During Critical Hours(MW)],       
   ISNULL(bmd.BMCMPData_CapacityBalance,0) as [Capacity Balance(MW)]       
 from       
   MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
 where        
    bmd.MtStatementProcess_ID=@pSettlementProcessId
	order by MPR.MtPartyRegisteration_Id;       
    ----------9.2------      
 select       
   ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],  
   MPR.MtPartyRegisteration_Id as [MP ID],         
   CASE  
  WHEN bmd.BMCMPData_CapacityBalance >= 0 THEN bmd.BMCMPData_CapacityBalance   
  ELSE 0  
 END AS [Capacity Balance(MW)]  
   --ISNULL(bvd.BMCVariablesData_CapacityBalancePositiveSum,0) as [Capacity Balance(MW)]       
 from       
   MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
   inner join BMCVariablesData bvd on bvd.MtStatementProcess_ID=bmd.MtStatementProcess_ID      
 where       
   bmd.MtStatementProcess_ID=@pSettlementProcessId          
   order by MPR.MtPartyRegisteration_Id;      
   -----------9.3------      
 select       
   ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],  
   MPR.MtPartyRegisteration_Id as [MP ID],          
   CASE  
  WHEN bmd.BMCMPData_CapacityBalance < 0 THEN bmd.BMCMPData_CapacityBalance   
  ELSE 0  
 END AS [Capacity Balance(MW)]  
   --ISNULL(bvd.BMCVariablesData_CapacityBalanceNegativeSum,0) as [Capacity Balance(MW)]       
 from       
   MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
   inner join BMCVariablesData bvd on bvd.MtStatementProcess_ID=bmd.MtStatementProcess_ID      
 where       
   bmd.MtStatementProcess_ID=@pSettlementProcessId          
   order by MPR.MtPartyRegisteration_Id;      
   ------------9.4-----      
   select      
   ROW_NUMBER() over (order by BMCVariablesData_Id) as [Sr],      
   BMCVariablesData_CapacityBalancePositiveSum as [Capacity Balance Positive (MW)],      
   BMCVariablesData_CapacityBalanceNegativeSum as [Capacity Balance Negative (MW)]       
   from BMCVariablesData      
   where       
   BMCVariablesData.MtStatementProcess_ID=@pSettlementProcessId       
   END      
      
   ELSE IF (@pStepId =10)      
         BEGIN      
   select  
   ROW_NUMBER() over (order by BMCVariablesData_Id) as [Sr],  
   bd.BMCVariablesData_EfficientDemandLevel_EDL  as [Efficient Demand Level (EDL) (MW)],      
   bd.BMCVariablesData_Slope as [Slope],       
   bd.BMCVariablesData_C_Constant as [C-Constant],      
   ISNULL(bd.BMCVariablesData_Point_D_Qty,0)  as [Point D Quantity (MW)],       
   bd.BMCVariablesData_CapacityPrice as [Capacity Price (PKR/MW/year)]       
 from      
   BMCVariablesData bd      
 where        
     bd.MtStatementProcess_ID=@pSettlementProcessId;     
              
   END      
      
 ELSE IF (@pStepId =11)      
         BEGIN   
	IF @vSrProcessDef_Id = 23 
	BEGIN
		  select ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],      
   MPR.MtPartyRegisteration_Id as [MP ID],      
   ABS(bmd.BMCMPData_CapacitySold) as [Capacity Sold by Market Participant(MW)],       
   ABS(bmd.BMCMPData_CapacityPurchased) as [Capacity Purchased by Market Participant(MW)]       
 from       
   MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
 where      
    bmd.MtStatementProcess_ID=@pSettlementProcessId
	order by MPR.MtPartyRegisteration_Id;
	END
	ELSE
	BEGIN

    select ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],      
   MPR.MtPartyRegisteration_Id as [MP ID],      
   ABS(bmd.BMCMPData_CapacitySold) as [Capacity Preliminary Sold by Market Participant(MW)],       
   ABS(bmd.BMCMPData_CapacityPurchased) as [Capacity Preliminary Allocated to Market Participant(MW)]       
 from       
   MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
 where      
    bmd.MtStatementProcess_ID=@pSettlementProcessId
	order by MPR.MtPartyRegisteration_Id;  
	END 
   END      
      
   ELSE IF (@pStepId =12)      
         BEGIN    
	IF @vSrProcessDef_Id = 23
	BEGIN
		 select ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],      
   MPR.MtPartyRegisteration_Id as [MP ID],      
   ABS(bmd.BMCMPData_CapacitySold) as [Capacity Sold by Market Participant(MW)],       
   ABS(bmd.BMCMPData_CapacityPurchased) as [Capacity Purchased byk Market Participant(MW)],      
   bvd.BMCVariablesData_CapacityPrice as [Capacity Price (PKR/MW/year)], 
   ABS(bmd.BMCMPData_AmountPayable) as [Total Amount Payable by MP (PKR)],
   ABS(bmd.BMCMPData_AmountReceivable) as [Total Amount Receivable by MP (PKR)]     
     
   from MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
   inner join BMCVariablesData bvd on bvd.MtStatementProcess_ID=bmd.MtStatementProcess_ID      
 where        
      bmd.MtStatementProcess_ID=@pSettlementProcessId
	  order by MPR.MtPartyRegisteration_Id;  
	
		
	END 

	ELSE
	BEGIN

    select ROW_NUMBER() over (order by MPR.MtPartyRegisteration_Id) as [Sr],      
   MPR.MtPartyRegisteration_Name as [MP Name],      
   MPR.MtPartyRegisteration_Id as [MP ID],      
   ABS(bmd.BMCMPData_CapacitySold) as [Capacity Preliminary Sold by Market Participant(MW)],       
   ABS(bmd.BMCMPData_CapacityPurchased) as [Capacity Preliminary Allocated to Market Participant(MW)],      
   bvd.BMCVariablesData_CapacityPrice as [Capacity Price (PKR/MW/year)], 
   ABS(bmd.BMCMPData_AmountPayable) as [Preliminary Amount Payable by MP (PKR)],
   ABS(bmd.BMCMPData_AmountReceivable) as [Preliminary Amount Receivable by MP (PKR)]     
     
   from MtPartyRegisteration MPR      
   inner join BMCMPData bmd on bmd.MtPartyRegisteration_Id=mpr.MtPartyRegisteration_Id      
   inner join BMCVariablesData bvd on bvd.MtStatementProcess_ID=bmd.MtStatementProcess_ID      
 where        
      bmd.MtStatementProcess_ID=@pSettlementProcessId
	  order by MPR.MtPartyRegisteration_Id;  
	  END 
   END   
   
   ELSE IF (@pStepId =13 AND @vSrProcessDef_Id = 23)
   BEGIN
		DECLARE
	   @vStatement_Id_Reference DECIMAL(18, 0)
	   ,@vLuAccountingMonth_Id DECIMAL(18, 0);
SELECT
	@vSrProcessDef_Id = msp.SrProcessDef_ID
   ,@vStatement_Id_Reference = msp.MtStatementProcess_ID
   ,@vLuAccountingMonth_Id = msp.LuAccountingMonth_Id_Current
FROM MtStatementProcess msp

WHERE msp.MtStatementProcess_ID = (SELECT
	TOP 1
		bm.MtStatementProcess_ID_Reference
	FROM BMCEYSSAdjustmentMPData bm
	WHERE bm.MtStatementProcess_ID = @pSettlementProcessId);

DROP TABLE IF EXISTS #PreviousBMCData;
CREATE TABLE #PreviousBMCData (
	MtPartyRegistration_Id DECIMAL(18, 0)
   ,CapacitySold DECIMAL(38, 13)
   ,CapacityPurchased DECIMAL(38, 13)
   ,AmountPayable DECIMAL(38, 13)
   ,AmountReceivable DECIMAL(38, 13)
)


IF @vSrProcessDef_Id = 22
BEGIN
	INSERT INTO #PreviousBMCData
		SELECT
			b.MtPartyRegisteration_Id
		   ,b.BMCPYSSMPData_CapacitySoldRevised
		   ,b.BMCPYSSMPData_CapacityPurchasedRevised
		   ,b.BMCPYSSMPData_AmountPayableRevised
		    ,b.BMCPYSSMPData_AmountReceivableRevised
		FROM BMCPYSSMPData b
		WHERE b.MtStatementProcess_ID = @vStatement_Id_Reference;
END
ELSE
IF @vSrProcessDef_Id = 23 
BEGIN
	SELECT
		b.MtPartyRegisteration_Id
	   ,b.BMCMPData_CapacitySold
	   ,b.BMCMPData_CapacityPurchased
	   ,b.BMCMPData_AmountPayable
	   ,b.BMCMPData_AmountReceivable

	FROM BMCMPData b
	WHERE b.MtStatementProcess_ID = @vStatement_Id_Reference
END

IF EXISTS (SELECT TOP 1
			1
		FROM #PreviousBMCData pb)
BEGIN
	DECLARE @vLuaccountingMonth_Name VARCHAR(200)
		   ,@vRefPeriod VARCHAR(200)
		   ,@vQuery NVARCHAR(MAX)
	SELECT
		@vRefPeriod =
		lam.LuAccountingMonth_MonthName
	FROM LuAccountingMonth lam
	WHERE lam.LuAccountingMonth_Id = @vLuAccountingMonth_Id

	SET @vLuaccountingMonth_Name =
	CONCAT(CASE
		WHEN @vSrProcessDef_Id = 22 THEN 'FYSS'
		ELSE 'EYSS'
	END, ' ', @vRefPeriod);

	SET @vQuery =
	'SELECT
	     ROW_NUMBER() over (order by EYSS.MtPartyRegisteration_Id) as [Sr] 
		,EYSS.MtPartyRegisteration_Id as [MP ID]
	   ,mpr.MtPartyRegisteration_Name as [MP Name]
	   ,RMP.BMCMPData_CapacitySold AS [Capacity Sold by Market Participant (MW)]
	   ,ABS(RMP.BMCMPData_CapacityPurchased) AS [Capacity Purchased by Market Participant (MW)]
	   ,bd.BMCVariablesData_CapacityPrice AS [Capacity Price (PKR/MW/year)]
	   ,ABS(RMP.BMCMPData_AmountPayable) AS [Total Amount Payable by MP (PKR)]
	   ,RMP.BMCMPData_AmountReceivable AS [Total Amount Receivable by MP (PKR)]
	   ,ABS(MP.AmountPayable) AS [Final Amount Payable by MP BMC- ' + @vLuaccountingMonth_Name + ' (PKR)]
	   ,MP.AmountReceivable AS [Final Amount Receivable by MP BMC- ' + @vLuaccountingMonth_Name + '(PKR)]
	   ,EYSS.BMCEYSSAdjustmentMPData_NetAmountPayable AS [Net Amount Payable by MP (PKR)]
	   ,EYSS.BMCEYSSAdjustmentMPData_NetAmountReceivable AS [Net Amount Receivable by MP (PKR)]
	   ,EYSS.BMCEYSSAdjustmentMPData_NetAdjustments AS [Adjustment from ESS (PKR)]
	FROM BMCEYSSAdjustmentMPData EYSS
	INNER JOIN #PreviousBMCData MP
		ON EYSS.MtPartyRegisteration_Id = MP.MtPartyRegistration_Id

	INNER JOIN MtPartyRegisteration mpr
		ON MP.MtPartyRegistration_Id = mpr.MtPartyRegisteration_Id
	INNER JOIN BMCVariablesData bd
		ON EYSS.MtStatementProcess_ID = bd.MtStatementProcess_ID
	INNER JOIN BMCMPData RMP
		ON RMP.MtStatementProcess_ID = EYSS.MtStatementProcess_ID
			AND RMP.MtPartyRegisteration_Id = EYSS.MtPartyRegisteration_Id

	WHERE EYSS.MtStatementProcess_ID = '+cast (@pSettlementProcessId AS VARCHAR(50))+'
	AND RMP.MtStatementProcess_ID = '+cast (@pSettlementProcessId AS VARCHAR(50))+'
	AND bd.MtStatementProcess_ID = '+cast (@pSettlementProcessId AS VARCHAR(50));

EXECUTE (@vQuery);

END



   END

   END      
 END TRY      
    BEGIN CATCH      
       
        DECLARE @vErrorMessage VARCHAR(MAX) = '';      
        SELECT      
            @vErrorMessage = 'BMC Process Output View Error: ' + ERROR_MESSAGE();      
        RAISERROR (@vErrorMessage, 16, -1);      
    END CATCH      
END      
