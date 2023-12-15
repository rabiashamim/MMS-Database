/****** Object:  Procedure [dbo].[GetMtAvgCriticalHoursCapacity_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================                  
-- Author: Aymen Khalid                    
-- CREATE date:  26/12/2022                                   
-- ALTER date:                                     
-- Reviewer:                                    
-- Description: Get Average Critical Hours Capacity data.                                 
-- =============================================                                     
-- =============================================             
    
CREATE PROCEDURE dbo.GetMtAvgCriticalHoursCapacity_Interface      
@pFileMasterId decimal(18,0)      
AS      
BEGIN      
      
SELECT *   
FROM MtAvgCriticalHoursCapacity_Interface    
WHERE       
 MtSOFileMaster_Id=@pFileMasterId      
 AND MtAvgCriticalHoursCapacity_IsDeleted IS NULL    
      
      
END 
