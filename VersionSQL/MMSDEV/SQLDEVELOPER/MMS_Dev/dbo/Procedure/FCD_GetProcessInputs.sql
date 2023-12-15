/****** Object:  Procedure [dbo].[FCD_GetProcessInputs]    Committed by VersionSQL https://www.versionsql.com ******/

    
--[dbo].[GetBmeSettlementInputs]    
CREATE   PROCEDURE dbo.FCD_GetProcessInputs        
@pMtFCDMaster decimal(18,0)   =0    ,
@pSrFCDProcessDef_Id int=0
    
AS        
BEGIN        
    
select     
RuInp.RuFCDInputDataset_Id as FCDInputDataset_Id,    
RuFCDInputDataset_Name as FCDInputDataset_Name,    
@pMtFCDMaster as MtFCDMaster_Id,    
--MtFCDProcessInput_Id as FCDInputDataset_Id,    
--MtFCDProcessInput_Version as FCDInputDataset_Version,    
--'' as FCDInputDataset_URL,    
RuFCDInputDataset_Description as FCDInputDataset_Description,    
LuSOFileTemplate_Id as LuSOFileTemplate_Id     
    
from RuFCDInputDataset RuInp    
---left join MtFCDProcessInput MtInp on MtInp.RuFCDInputDataset_Id=RuInp.RuFCDInputDataset_Id    
--and MtInp.MtFCDMaster_Id=@pMtFCDMaster  
where --ISNULL(MtFCDProcessInput_IsDeleted,0)=0    AND
 ISNULL(RuFCDInputDataset_IsDeleted,0)=0    
 and RuInp.SrFCDProcessDef_Id=@pSrFCDProcessDef_Id
END  
  
  
