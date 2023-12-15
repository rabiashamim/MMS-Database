/****** Object:  Procedure [dbo].[ContractReg_GetContractType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure dbo.ContractReg_GetContractType
@pContractId as int=0
as
BEGIN


select SrContractType_Id as ContractId,
       SrContractType_Name as ContractName
from SrContractType
where @pContractId=0 or SrContractType_Id=@pContractId
END
