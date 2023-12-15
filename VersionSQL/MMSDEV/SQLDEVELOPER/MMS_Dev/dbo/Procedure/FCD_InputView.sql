/****** Object:  Procedure [dbo].[FCD_InputView]    Committed by VersionSQL https://www.versionsql.com ******/

--    dbo.FCD_InputView     7,3
  
CREATE   PROCEDURE dbo.FCD_InputView      
@pMtFCDMaster_Id decimal(18,0), 
@pStepId int   
AS      
BEGIN      
Declare @FromYear int , @ToYear int
select @FromYear=MtFCDMaster_YearFrom, @ToYear=MtFCDMaster_YearTo from MtFCDMaster where MtFCDMaster_Id=@pMtFCDMaster_Id

--select * from RuFCDInputDataset
if(@pStepId=1)
BEGIN
select distinct
G.MtGenerator_Id as [Generator Id]
,G.MtGenerator_Name as [Generator Name]
,MtAnnualDependableCapacityADC_Date as [Date]
,MtAnnualDependableCapacityADC_Value as [ADC Value]
from MtAnnualDependableCapacityADC ADC
Inner join MtGenerator G on G.MtGenerator_Id=ADC.MtGenerator_Id
where
DATEPART(Year, MtAnnualDependableCapacityADC_Date)>=@FromYear
AND DATEPART(Year, MtAnnualDependableCapacityADC_Date)<=@ToYear
AND ISNULL(MtAnnualDependableCapacityADC_IsDeleted,0)=0
AND ISNULL(isDeleted,0)=0
AND ISNULL(MtGenerator_IsDeleted,0)=0
order by G.MtGenerator_Id, MtAnnualDependableCapacityADC_Date
END
ELSE IF(@pStepId=2)
BEGIN
select 
G.MtGenerator_Id as [Generator Id],
G.MtGenerator_Name as [Generator Name],
DATEFROMPARTS(MTGenerationFirmCapacityHourlyData_year, MTGenerationFirmCapacityHourlyData_Month, MTGenerationFirmCapacityHourlyData_Day) as [Date],
MTGenerationFirmCapacityHourlyData_Hour as [Hour],
MTGenerationFirmCapacityHourlyData_Generation as [Generation],
MTGenerationFirmCapacityHourlyData_Curtailment as [Curtailment],
MTGenerationFirmCapacityHourlyData_SoForecast as [SO Forecast],
MTGenerationFirmCapacityHourlyData_EnergyNonExistent as [Energy NonExistent]

from MTGenerationFirmCapacityHourlyData FirmCap
Inner join MtGenerator G on G.MtGenerator_Id=FirmCap.MtGenerator_Id
where MTGenerationFirmCapacityHourlyData_year>=@FromYear
and MTGenerationFirmCapacityHourlyData_year<=@ToYear
AND ISNULL(isDeleted,0)=0
AND ISNULL(MtGenerator_IsDeleted,0)=0
order by G.MtGenerator_Id, MTGenerationFirmCapacityHourlyData_year, MTGenerationFirmCapacityHourlyData_Month, MTGenerationFirmCapacityHourlyData_Day, MTGenerationFirmCapacityHourlyData_Hour

END
ELSE IF(@pStepId=3)
BEGIN
select distinct
G.MtGenerator_Id as [Generator Id]
,G.MtGenerator_Name as [Generator Name]
,MtAvailibilityData_Date	 as [Date]
,MtAvailibilityData_Hour	as [Hour]
,MtAvailibilityData_AvailableCapacityASC	as [Available Capacity ASC]
,MtAvailibilityData_ActualCapacity as [Actual Capacity]
from MtAvailibilityData A
inner join MtGenerationUnit GU on GU.MtGenerationUnit_Id=A.MtGenerationUnit_Id
inner join MtGenerator G on G.MtGenerator_Id=GU.MtGenerator_Id
where
 DATEPART(year, a.MtAvailibilityData_Date)>=@FromYear
and DATEPART(year, a.MtAvailibilityData_Date)<=@ToYear
and isnull(G.isDeleted,0)=0
and ISNULL(G.MtGenerator_IsDeleted,0)=0
and ISNULL(GU.isDeleted,0)=0
and ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
and ISNULL(A.MtAvailibilityData_IsDeleted,0)=0
order by G.MtGenerator_Id, A.MtAvailibilityData_Date, A.MtAvailibilityData_Hour

END

ELSE
BEGIN

SELECT 
 FCD.MtGenerator_Id	AS id
,G.MtGenerator_Name AS [Name]
,FCD.MTGenerationFirmCapacityHourlyData_year	AS [Year]
,FCD.MTGenerationFirmCapacityHourlyData_Month	AS [Month]
,FCD.MTGenerationFirmCapacityHourlyData_Day	 AS [Day]
,FCD.MTGenerationFirmCapacityHourlyData_Hour	AS [Hour]
,FCD.MTGenerationFirmCapacityHourlyData_Generation	AS [Generation]
,FCD.MTGenerationFirmCapacityHourlyData_Curtailment	AS [Curtailment]
,FCD.MTGenerationFirmCapacityHourlyData_SoForecast	AS [SoForecast]
,FCD.MTGenerationFirmCapacityHourlyData_EnergyNonExistent AS [Energy Non Existent]

FROM MTGenerationFirmCapacityHourlyData FCD
JOIN MtGenerator G ON G.MtGenerator_Id=FCD.MtGenerator_Id
END
END
