/****** Object:  Procedure [dbo].[ContractReg_RemoveContractProfileCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ali Imran
-- CREATE date: Nov 15, 2022 
-- ALTER date: 
-- Reviewer:
-- Description: 
-- ============================================= 

CREATE   PROCEDURE dbo.ContractReg_RemoveContractProfileCapacity
	@pContractProfileCapacity_Id DECIMAL(18, 0)
	,@pUserId INT
AS
BEGIN

	UPDATE [dbo].[MtContractProfileCapacity] 
	SET MtContractProfileCapacity_IsDeleted=1
	,MtContractProfileCapacity_ModifiedBy=@pUserId
	,MtContractProfileCapacity_ModifiedOn=GETUTCDATE()
	WHERE MtContractProfileCapacity_Id = @pContractProfileCapacity_Id
	

END
