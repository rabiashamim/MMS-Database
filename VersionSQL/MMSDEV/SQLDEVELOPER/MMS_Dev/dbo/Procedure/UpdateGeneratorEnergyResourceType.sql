/****** Object:  Procedure [dbo].[UpdateGeneratorEnergyResourceType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================            
-- Author:  Aymen Khalid           
-- Create date: <10-03-2023>            
-- Description: <Description,,>            
-- =============================================            
CREATE PROCEDURE dbo.UpdateGeneratorEnergyResourceType            
@pdMtGeneratorId decimal(18,0),    
@pbDispatchable bit    
    
AS            
BEGIN            
    
IF @pbDispatchable = 1    
BEGIN    
 UPDATE MtGenerator set LuEnergyResourceType_Code = 'NDP' WHERE MtGenerator_Id = @pdMtGeneratorId    
 SELECT @@rowcount     
END    
ELSE IF  @pbDispatchable = 0    
BEGIN    
 UPDATE MtGenerator set LuEnergyResourceType_Code = 'DP' WHERE MtGenerator_Id = @pdMtGeneratorId    
 SELECT @@rowcount     
END       
           
END 
