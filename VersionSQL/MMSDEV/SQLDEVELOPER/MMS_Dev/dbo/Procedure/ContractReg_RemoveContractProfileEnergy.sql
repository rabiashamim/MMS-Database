/****** Object:  Procedure [dbo].[ContractReg_RemoveContractProfileEnergy]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ali Imran
-- CREATE date: Nov 15, 2022 
-- ALTER date: 
-- Reviewer:
-- Description: 
-- ============================================= 

CREATE   PROCEDURE dbo.ContractReg_RemoveContractProfileEnergy
	@pContractProfileEnergy_Id DECIMAL(18, 0),
	@pUserId INT
AS
BEGIN

	UPDATE [dbo].[MtContractProfileEnergy] 
	SET MtContractProfileEnergy_IsDeleted=1
	,MtContractProfileEnergy_ModifiedBy=@pUserId
	,MtContractProfileEnergy_ModifiedOn=GETUTCDATE()
	WHERE MtContractProfileEnergy_Id = @pContractProfileEnergy_Id
	

END
