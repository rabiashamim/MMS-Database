/****** Object:  Procedure [dbo].[ContractReg_GetContractSubType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure dbo.ContractReg_GetContractSubType    
@pContractId AS int=0    
AS    
BEGIN    
    
    
SELECT SrSubContractType AS SubContractId,    
       SrSubContractType_Name AS SubContractName    
FROM SrContractType  c   
  inner join SrSubContractType sc   
  ON c.SrContractType_Id=sc.SrContractType_Id  
WHERE c.SrContractType_Id=@pContractId  
  
END  
    
    
