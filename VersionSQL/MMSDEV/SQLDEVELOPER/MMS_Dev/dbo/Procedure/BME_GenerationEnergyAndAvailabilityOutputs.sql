/****** Object:  Procedure [dbo].[BME_GenerationEnergyAndAvailabilityOutputs]    Committed by VersionSQL https://www.versionsql.com ******/

-- dbo.BME_GenerationEnergyAndAvailabilityOutputs 25  
CREATE procedure dbo.BME_GenerationEnergyAndAvailabilityOutputs  
@pStatementProcessId  decimal(18,0)  
AS  
Begin  
  
select   
BmeStatementData_Month as Month,  
BmeStatementData_Day as Day,  
BmeStatementData_Hour as Hour,  
BmeStatementData_MtGenerator_Id as [Generator Id],  
dbo.GetGeneratorName(BmeStatementData_MtGenerator_Id) as [Generator Name],  
BmeStatementData_MtGeneratorUnit_Id as [Generation Unit ID],  
dbo.GetGenerationUnitName(BmeStatementData_SOUnitId) as [Generation Unit Name],  
BmeStatementData_SOUnitId as [SO Unit ID],  
BmeStatementData_GenerationUnitEnergy as [Generation Unit Energy]  
,BmeStatementData_UnitWiseGeneration as [Unit wise generation],   
BmeStatementData_AvailableCapacityASC as [Available Capacity ASC],  
BmeStatementData_CalculatedAvailableCapacityASC as [Calculated Available Capacity ASC]  
--,BmeStatementData_GenerationUnitWiseBackfeed  
,case when BmeStatementData_UnitWiseGenerationBackFeed=1 then 'Line' ELSE 'Unit' end AS [CDP Location]  
from [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess]   
where BmeStatementData_StatementProcessId=@pStatementProcessId  
  
END
