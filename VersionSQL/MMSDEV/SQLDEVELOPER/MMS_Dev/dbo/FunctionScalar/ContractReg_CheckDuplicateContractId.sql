/****** Object:  ScalarFunction [dbo].[ContractReg_CheckDuplicateContractId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION dbo.ContractReg_CheckDuplicateContractId
(
@pUserContractId nvarchar (100) ,
@pContractId decimal(18,0)
)
RETURNS  int
AS
BEGIN
	DECLARE @vIsAlreadyExists as int=0

	select @vIsAlreadyExists=count(1) from MtContractRegistration 
	where MtContractRegistration_ContractId=@pUserContractId
	and (MtContractRegistration_Id<>@pContractId or @pContractId=0)
	and ISNULL(MtContractRegistration_IsDeleted,0)=0

	RETURN @vIsAlreadyExists

END
