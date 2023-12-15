/****** Object:  Procedure [dbo].[MtGenerator_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================            
-- Author:  Kapil Kumar | Alina javed          
-- Create date: Dec 14, 2022          
-- Description: <Description,,>            
-- =============================================            
CREATE   PROCEDURE dbo.MtGenerator_Update            
@pGeneratorId int,    
@pGeneratorName varchar(100)  ,          
@pGenerator_TotalInstalledCapacity decimal(18, 4) ,          
@pPowerPolicy_Id int = null,          
@pCapUnitGenVari_Id int = null,          
@pGenerator_Location varchar(MAX) ,          
@pMtGenerator_IsDisabled bit,        
@pEffectiveFrom datetime,          
@pEffectiveTo DATETIME = NULL,   
@pCod_Date Datetime,  
@pUserId decimal(18,0),
@pGenerator_NewInstalledCapacity DECIMAL(18,4) = NULL,
@pGenerator_FOR DECIMAL(18,5) = NULL
    
    
          
AS            
BEGIN         
    
    
Update [MtGenerator]    
set [MtGenerator_Name] = @pGeneratorName,    
 [MtGenerator_TotalInstalledCapacity] = @pGenerator_TotalInstalledCapacity,    
 [Lu_PowerPolicy_Id] = @pPowerPolicy_Id,    
 [Lu_CapUnitGenVari_Id] = @pCapUnitGenVari_Id,    
 [MtGenerator_Location] = @pGenerator_Location,    
 [MtGenerator_IsDisabled] = @pMtGenerator_IsDisabled,    
 [MtGenerator_EffectiveFrom] = CONVERT(DATETIME,@pEffectiveFrom,103),    
 [MtGenerator_EffectiveTo] = Cast(@pEffectiveTo as datetime),   
 [COD_Date]=CONVERT(DATETIME,@pCod_Date,103),   
 [MtGenerator_ModifiedBy] = @pUserId,    
 [MtGenerator_ModifiedOn] = GETUTCDATE(),
 MtGenerator_NewInstalledCapacity = @pGenerator_NewInstalledCapacity,
 MtGenerator_FOR = @pGenerator_FOR
where [MtGenerator_Id] = @pGeneratorId    
     
            
END            
          
          
          
          
