/****** Object:  Procedure [dbo].[ContractReg_GetPhysicalAssetsList_bk]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  SADAF MALIK  
-- CREATE date: Nov 18, 2022   
-- ALTER date:   
-- Reviewer:  
-- Description:   
-- =============================================   


-- [dbo].[ContractReg_GetPhysicalAssetsList] 1, 'Seller',1112,1108,13,10    
CREATE PROCEDURE dbo.ContractReg_GetPhysicalAssetsList_bk
    @pContractId decimal(18, 0),
    @pUserId int = 0,
    @pMeterOwner varchar(20) = null,
    @pBuyerId decimal(18, 0) = 0,
    @pSellerId decimal(18, 0) = 0,
    @pBuyerCategoryId decimal(18, 0) = 0,
    @pSellerCategoryId decimal(18, 0) = 0
AS
BEGIN

    SELECT physical.MtContractPhysicalAssets_Id,
           [MtGenerator_Name],
           [MtGenerationUnit_UnitName],
           [MtGenerator_Id],
           view1.[MtGenerationUnit_Id],
           FORMAT([Gen Unit Installed Capacity], 'N2') AS MtGenerationUnit_InstalledCapacity_KW,
           FORMAT(physical.MtContractPhysicalAssetsـPercentInstallEnergyTransaction, 'N2') AS PercentInstallEnergyTransaction,
           FORMAT(physical.MtContractPhysicalAssetsـPercentInstallCapacityTransaction, 'N2') AS PercentInstallCapacityTransaction,
           FORMAT(physical.MtContractPhysicalAssetsـPercentAssignedASCBuyer, 'N2') AS PercentAssignedASCBuyer,
           FORMAT(physical.MtContractPhysicalAssetsـPercentAssignedASCSeller, 'N2') AS PercentAssignedASCSeller
    FROM vw_CdpGenerators view1
        INNER JOIN MtContractTradingCDPs trading
            ON view1.RuCDPDetail_Id = trading.RuCDPDetail_Id
        LEFT JOIN MtContractPhysicalAssets physical
            ON physical.MtGenerationUnit_Id = view1.MtGenerationUnit_Id
    WHERE MtPartyCategory_Id = CASE
                                   WHEN @pMeterOwner = 'Buyer' THEN
                                       @pBuyerCategoryId
                                   ELSE
                                       @pSellerCategoryId
                               END
          and trading.MtContractRegistration_Id = @pContractId
END
