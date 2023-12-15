/****** Object:  Procedure [dbo].[ContractReg_GetPhysicalAssetsList]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================    
-- Author:  SADAF MALIK  
-- CREATE date: Nov 18, 2022   
-- ALTER date:   
-- Reviewer:  
-- Description:   
-- =============================================   


-- dbo.ContractReg_GetPhysicalAssetsList 1, 'Seller',1112,1108,13,10    
CREATE   PROCEDURE dbo.ContractReg_GetPhysicalAssetsList @pContractId DECIMAL(18, 0),
@pUserId INT = 0,
@pMeterOwner VARCHAR(20) = NULL,
@pBuyerId DECIMAL(18, 0) = 0,
@pSellerId DECIMAL(18, 0) = 0,
@pBuyerCategoryId DECIMAL(18, 0) = 0,
@pSellerCategoryId DECIMAL(18, 0) = 0
AS
BEGIN

-----------------------------------------------------------------------------------------------
-------------------------------Select Gen unit info w.r.t Trading Points ----------------------
-----------------------------------------------------------------------------------------------
SELECT DISTINCT
		[MtGenerator_Name]
	   ,[MtGenerationUnit_UnitName]
	   ,[MtGenerator_Id]
	   ,cdpGen.[MtGenerationUnit_Id]
	   ,cdpGen.[Gen Unit Installed Capacity] AS InstalledCapacity INTO #temp1
	FROM vw_CdpGenerators cdpGen
	WHERE MtPartyCategory_Id IN
	(SELECT MtPartyCategory_Id FROM MtPartyCategory WHERE MtPartyCategory_Id IN (@pBuyerCategoryId,@pSellerCategoryId) AND SrCategory_Code='GEN')
	

	/* commented by ali imran with the direction of Zeeshan and Adeel from MOD.
	SELECT DISTINCT
		[MtGenerator_Name]
	   ,[MtGenerationUnit_UnitName]
	   ,[MtGenerator_Id]
	   ,cdpGen.[MtGenerationUnit_Id]
	   ,cdpGen.[Gen Unit Installed Capacity] AS InstalledCapacity INTO #temp1
	FROM vw_CdpGenerators cdpGen
	INNER JOIN MtContractTradingCDPs trading
		ON cdpGen.RuCDPDetail_Id = trading.RuCDPDetail_Id
	WHERE MtPartyCategory_Id =
	CASE
		WHEN 'Buyer'=@pMeterOwner THEN 
		@pBuyerCategoryId
		ELSE @pSellerCategoryId
	END
	AND trading.MtContractRegistration_Id = @pContractId
	AND trading.MtContractTradingCDPs_IsDeleted = 0
	*/

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

	SELECT

		PA.MtContractPhysicalAssets_Id
	   ,[MtGenerator_Name]
	   ,[MtGenerationUnit_UnitName]
	   ,[MtGenerator_Id]
	   ,t.[MtGenerationUnit_Id]
	   ,FORMAT(t.InstalledCapacity, 'N2') AS MtGenerationUnit_InstalledCapacity_KW
	   ,FORMAT(PA.MtContractPhysicalAssetsـPercentInstallEnergyTransaction, 'N2') AS PercentInstallEnergyTransaction
	   ,FORMAT(PA.MtContractPhysicalAssetsـPercentInstallCapacityTransaction, 'N2') AS PercentInstallCapacityTransaction
	   ,FORMAT(PA.MtContractPhysicalAssetsـPercentAssignedASCBuyer, 'N2') AS PercentAssignedASCBuyer
	   ,FORMAT(PA.MtContractPhysicalAssetsـPercentAssignedASCSeller, 'N2') AS PercentAssignedASCSeller

	FROM #temp1 t
	LEFT JOIN MtContractPhysicalAssets PA
		ON PA.MtGenerationUnit_Id = t.MtGenerationUnit_Id
			AND PA.MtContractRegistration_Id = @pContractId
			AND PA.MtContractPhysicalAssets_IsDeleted = 0







END
