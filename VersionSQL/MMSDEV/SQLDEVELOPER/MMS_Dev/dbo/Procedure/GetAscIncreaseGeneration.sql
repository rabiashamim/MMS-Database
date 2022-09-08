/****** Object:  Procedure [dbo].[GetAscIncreaseGeneration]    Committed by VersionSQL https://www.versionsql.com ******/

  
-- GetAscIncreaseGeneration 189  
CREATE PROCEDURE [dbo].[GetAscIncreaseGeneration]    
@pFileMasterId decimal(18,0)    
AS    
BEGIN    
    
SELECT   
*,
GenerationUnitName = dbo.GetGenerationUnitName(MtGenerationUnit_Id) 

FROM   
 MtAscIG 
WHERE   
 MtSOFileMaster_Id=@pFileMasterId 
 
  
END
