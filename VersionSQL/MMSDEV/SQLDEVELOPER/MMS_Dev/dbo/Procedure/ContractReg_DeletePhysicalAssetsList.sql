/****** Object:  Procedure [dbo].[ContractReg_DeletePhysicalAssetsList]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================  
-- Author: Kapil Kumar
-- CREATE date: Nov 24, 2022 
-- ALTER date: 
-- Reviewer:
-- Description: 
-- ============================================= 

CREATE PROCEDURE dbo.ContractReg_DeletePhysicalAssetsList
	@pMtContractPhysicalAssets_Id DECIMAL(18, 0) = NULL
	
AS
BEGIN
				delete from [dbo].[MtContractPhysicalAssets]
				where MtContractPhysicalAssets_Id = @pMtContractPhysicalAssets_Id
				
				

END
