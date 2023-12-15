/****** Object:  Procedure [dbo].[GetMtAvgCriticalHoursCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================              
-- Author: Aymen Khalid                
-- CREATE date:  20/12/2022                               
-- ALTER date:                                 
-- Reviewer:                                
-- Description: Get Average Critical Hours Capacity data.                             
-- =============================================                                 
-- =============================================         

CREATE PROCEDURE dbo.GetMtAvgCriticalHoursCapacity  
@pFileMasterId decimal(18,0)  
AS  
BEGIN  
  
SELECT *,
GenerationUnitName = dbo.GetGenerationUnitName(MtAvgCriticalHoursCapacity_SOUnitId)   
FROM MtAvgCriticalHoursCapacity
WHERE   
 MtSOFileMaster_Id=@pFileMasterId  
 AND MtAvgCriticalHoursCapacity_IsDeleted IS NULL
  
  
END  
