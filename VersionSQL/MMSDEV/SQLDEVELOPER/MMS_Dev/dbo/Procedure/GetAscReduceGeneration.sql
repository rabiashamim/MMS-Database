/****** Object:  Procedure [dbo].[GetAscReduceGeneration]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetAscReduceGeneration]  
@pFileMasterId decimal(18,0)  
AS  
BEGIN  
  
SELECT 
	*,
	GenerationUnitName = dbo.GetGenerationUnitName(MtGenerationUnit_Id) 
FROM 
	MtAscRG  
WHERE 
	MtSOFileMaster_Id=@pFileMasterId
  
  
  
END
