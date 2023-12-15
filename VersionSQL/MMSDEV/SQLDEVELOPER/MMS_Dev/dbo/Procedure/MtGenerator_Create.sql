/****** Object:  Procedure [dbo].[MtGenerator_Create]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================          
-- Author:  Kapil Kumar| Alina javed          
-- Create date: Dec 13, 2022        
-- Description: <Description,,>          
-- =============================================          
CREATE PROCEDURE dbo.MtGenerator_Create          
@pPartyCategoryId decimal(18,0)  ,        
@pGeneratorName varchar(100)  ,        
@pGenerator_TotalInstalledCapacity decimal(18, 4) ,        
@pPowerPolicy_Id int = null,        
@pCapUnitGenVari_Id int = null,        
@pGenerator_Location varchar(MAX) ,        
@pMtGenerator_IsDisabled bit,      
@pEffectiveFrom datetime,        
@pEffectiveTo DATETIME = NULL,   
@pCod_Date Datetime = NULL,
@pUserId decimal(18,0)  ,
@pGenerator_NewInstalledCapacity DECIMAL(18,4) = NULL,
@pGenerator_FOR DECIMAL(18,5) = NULL
        
AS          
BEGIN          
insert into [dbo].[MtGenerator]        
([MtGenerator_Id]        
,[MtPartyCategory_Id]        
,[MtGenerator_Name]        
,[MtGenerator_TotalInstalledCapacity]  
,MtGenerator_NewInstalledCapacity
,MtGenerator_FOR
,[Lu_PowerPolicy_Id]         
,[Lu_CapUnitGenVari_Id]        
,[MtGenerator_Location]        
,[MtGenerator_IsDisabled]         
,[MtGenerator_EffectiveFrom]        
,[MtGenerator_EffectiveTo]  
,[Cod_Date]
,[MtGenerator_CreatedBy]        
,[MtGenerator_CreatedOn])          
        
  OUTPUT INSERTED.MtGenerator_Id      
                            
     VALUES( (SELECT IsNull(MAX( [MtGenerator_Id] ) + 1,1) from MtGenerator)        
     ,@pPartyCategoryId        
     ,@pGeneratorName        
     ,@pGenerator_TotalInstalledCapacity  
	 ,@pGenerator_NewInstalledCapacity
	 ,@pGenerator_FOR
     ,@pPowerPolicy_Id        
     ,@pCapUnitGenVari_Id        
     ,@pGenerator_Location        
     ,@pMtGenerator_IsDisabled      
     ,CONVERT(DATETIME,@pEffectiveFrom,103)    
  ,Cast(@pEffectiveTo as datetime)  
     ,--CONVERT(DATETIME, @pCod_Date,103)
	 Cast(@pCod_Date as datetime) 
     ,@pUserId        
     ,GETUTCDATE())        
      
  select @@identity        
          
END          
        
        
        
        
        
