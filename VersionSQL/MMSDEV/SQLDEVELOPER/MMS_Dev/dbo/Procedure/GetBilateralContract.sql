/****** Object:  Procedure [dbo].[GetBilateralContract]    Committed by VersionSQL https://www.versionsql.com ******/

  
-- GetAscIncreaseGeneration 5  
CREATE PROCEDURE [dbo].[GetBilateralContract]   
@pFileMasterId decimal(18,0)    
AS    
BEGIN    
    
SELECT   
 *   
FROM   
MTBilateralContract   
WHERE   
 MtSOFileMaster_Id=@pFileMasterId  
    
    
    
END
