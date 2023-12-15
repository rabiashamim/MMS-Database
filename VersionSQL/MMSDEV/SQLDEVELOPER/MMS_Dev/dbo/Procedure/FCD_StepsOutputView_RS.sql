/****** Object:  Procedure [dbo].[FCD_StepsOutputView_RS]    Committed by VersionSQL https://www.versionsql.com ******/

      
CREATE   PROCEDURE dbo.FCD_StepsOutputView_RS       
@pMtFCDMaster_Id decimal(18,0),     
@pStepId int       
AS          
BEGIN          
    
if exists(    
select top 1 1 from MtGenerator where MtGenerator_Id in (    
select MtGenerator_Id from MtFCDGenerators where MtFCDMaster_Id=@pMtFCDMaster_Id    
and ISNULL(MtFCDGenerators_IsDeleted,0)=0    
)    
and ISNULL(isDeleted,0)=0    
and ISNULL(MtGenerator_IsDeleted,0)=0    
and LuEnergyResourceType_Code='NDP'    
    
)  and @pStepId in (1,3)  
BEGIN    
select     
DATEFROMPARTS(MtFCDHourlyData_Year ,MtFCDHourlyData_Month, MtFCDHourlyData_Day) as [Date],    
MtFCDHourlyData_Hour as [Hour],    
G.MtGenerator_Name as [MMS Generator Name],    
T.SrTechnologyType_Name as [Technology],    
FCD.MtGenerator_Id as [MMS Gen ID],    
FCD.MtFCDHourlyData_SOForecast as [Forecast(MW)],    
FCD.MtFCDHourlyData_Curtailment as [Curtailemnt(MW)],    
FCD.MtFCDHourlyData_Generation as [Generation(MW)],    
G.MtGenerator_TotalInstalledCapacity as [Installed Capacity]    
--,1 as calculation    
from [dbo].[MtFCDHourlyData] FCD    
JOIN MtGenerator G on G.MtGenerator_Id=FCD.MtGenerator_Id    
inner join MtGenerationUnit GU on GU.MtGenerator_Id=G.MtGenerator_Id    
inner join SrTechnologyType T on T.SrTechnologyType_Code=GU.SrTechnologyType_Code    
where MtFCDMaster_Id=@pMtFCDMaster_Id    
and isnull(G.isdeleted,0)=0    
and isnull(MtGenerator_IsDeleted,0)=0    
and isnull(GU.isDeleted,0)=0    
and isnull(GU.MtGenerationUnit_IsDeleted,0)=0    
order by FCD.MtGenerator_Id , MtFCDHourlyData_Year ,MtFCDHourlyData_Month, MtFCDHourlyData_Day    
END    

if exists(    
select top 1 1 from MtGenerator where MtGenerator_Id in (    
select MtGenerator_Id from MtFCDGenerators where MtFCDMaster_Id=@pMtFCDMaster_Id    
and ISNULL(MtFCDGenerators_IsDeleted,0)=0    
)    
and ISNULL(isDeleted,0)=0    
and ISNULL(MtGenerator_IsDeleted,0)=0    
and LuEnergyResourceType_Code='DP'    
    
)  and @pStepId in(2,3)
    
SELECT    
G.MtGenerator_Id AS [Generator Id]    
,G.MtGenerator_Name AS [Generator Name]    
--,FG.MtFCDGenerators_TotalGeneration AS [Total Generation]    
--,FG.MtFCDGenerators_EnergyGeneratedDuringCurtailment AS [Energy Generation During Curtailment]    
,FG.MtFCDGenerators_InitialFirmCapacity AS [Initial Firm Capacity IFC]    
from MtFCDGenerators FG    
JOIN MtGenerator G ON G.MtGenerator_Id=FG.MtGenerator_Id    
WHERE     
MtFCDMaster_Id=@pMtFCDMaster_Id    
END    
