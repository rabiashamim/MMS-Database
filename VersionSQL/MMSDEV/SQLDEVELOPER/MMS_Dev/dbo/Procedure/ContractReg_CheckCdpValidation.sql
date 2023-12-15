/****** Object:  Procedure [dbo].[ContractReg_CheckCdpValidation]    Committed by VersionSQL https://www.versionsql.com ******/

-------------------------------------------------------------------------------------------------------------------------------------      
 -- Validation need to be implemented to check if selected CDPs as Trading Points are already involved in other contracts.       
 ------------------------------------------------------------------------------------------------------------------------------------      
-- =============================================          
-- Author:  Kapil Kumar | Ali Imran      
-- CREATE OR ALTER date: Dec 05, 2022         
-- ALTER date:     30-08-2023     
-- Reviewer:        
-- Description:         
-- =============================================            
CREATE   PROCEDURE dbo.ContractReg_CheckCdpValidation         
@pMtContractRegistration_Id DECIMAL(18, 0),        
@pRuCDPDetail_Id VARCHAR(MAX)      
AS        
BEGIN        
--------------------------------------------------------------------------------------        


/* update at 30-08-2023
*  Task id 3730
*/


IF (@pRuCDPDetail_Id IS NULL OR @pRuCDPDetail_Id='')
BEGIN
IF NOT EXISTS(SELECT top 1 1 FROM MtContractRegistration CR WHERE CR.MtContractRegistration_Id=@pMtContractRegistration_Id AND CR.SrContractType_Id=3)
BEGIN
		select 'Please select any CDP';  			
END
END

 declare @ContractTradingCdpCount as int=0;       
 declare @cdps as NVARCHAR(500);      
      
 drop table if exists #selectedCdps      
        
 SELECT        
  RuCDPDetail_Id        
    ,RuCDPDetail_CdpId, RuCDPDetail_CdpName INTO #selectedCdps        
 FROM RuCDPDetail        
 WHERE RuCDPDetail_CdpId IN (SELECT        
   value        
  FROM STRING_SPLIT(@pRuCDPDetail_Id, ','));        
        
      
 select @ContractTradingCdpCount = count(*) from MtContractTradingCDPs       
 where RuCDPDetail_Id in (select RuCDPDetail_Id from #selectedCdps)       
  and MtContractRegistration_Id <> @pMtContractRegistration_Id      
  and MtContractTradingCDPs_IsDeleted = 0      
      
      
 if (@ContractTradingCdpCount> 0)      
  begin      
    
  select distinct @cdps= STRING_AGG('Contract # '+CAST(MCT.MtContractRegistration_Id as varchar(18)) + ' -  CDP: '+cdp.RuCDPDetail_CdpId, '<br>')    
  from MtContractTradingCDPs MCT    
  inner join RuCDPDetail cdp on cdp.RuCDPDetail_Id=MCT.RuCDPDetail_Id    
  where MCT.RuCDPDetail_Id in (select RuCDPDetail_Id from #selectedCdps)      
  and MCT.MtContractRegistration_Id <> @pMtContractRegistration_Id      
  and MtContractTradingCDPs_IsDeleted = 0      
    
SET @cdps = 'Please reassess selection of following CDP(s) as Trading Points for this contract. <br>' + @cdps + ' '  
    
  select @cdps;  
    
  end      
      
 END 
