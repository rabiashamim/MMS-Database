/****** Object:  Procedure [dbo].[ContractReg_GetPartyCategory]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
CREATE procedure dbo.ContractReg_GetPartyCategory         
@pMtPartyRegisteration_Id decimal(18, 0) = null        
as        
select PC.MtPartyCategory_Id AS CategoryId,        
       SrCategory_Name AS CategoryName      
from MtPartyCategory PC        
    inner join SrCategory C        
        on PC.SrCategory_Code = C.SrCategory_Code        
where MtPartyRegisteration_Id = @pMtPartyRegisteration_Id  
and isnull(isDeleted,0)=0  
--AND PC.LuStatus_Code in ('MDRA','AAPR','MAPR')
