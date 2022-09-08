/****** Object:  Procedure [dbo].[BME_GenerationEnergyAndAvailabilityOutputs]    Committed by VersionSQL https://www.versionsql.com ******/

create procedure BME_GenerationEnergyAndAvailabilityOutputs
@pStatementProcessId  decimal(18,0)
AS
Begin

select  BmeStatementData_Month,	BmeStatementData_Day,	BmeStatementData_Hour,	BmeStatementData_MtGenerator_Id	,BmeStatementData_MtGeneratorUnit_Id,	BmeStatementData_SOUnitId,
BmeStatementData_GenerationUnitEnergy
,BmeStatementData_UnitWiseGeneration, 
BmeStatementData_AvailableCapacityASC,
BmeStatementData_CalculatedAvailableCapacityASC

from [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess] 
where BmeStatementData_StatementProcessId=@pStatementProcessId
END
