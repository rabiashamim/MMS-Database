/****** Object:  Procedure [dbo].[ContractReg_GetContractTradingCdps_bk_18-Nov]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:       
-- CREATE date: 15/11/2022      
-- ALTER date:         

-- Description:       
-- This SP returns the relevant CDP points for a registered contract.      
--      

-- Parameters: @pBilateralContractId      
-- =============================================       
-- [ContractReg_GetContractTradingCdps] 19     
CREATE PROCEDURE dbo.ContractReg_GetContractTradingCdps_bk_18-Nov (@pBilateralContractId INT)
AS
BEGIN
    BEGIN TRY

        DECLARE @vMeterOwnerId INT,
                @vCategoryCode VARCHAR(4),
                @vPartyCategoryId INT;


        --- 1. Get Meter Owner ID and party category ID.      
        SELECT @vMeterOwnerId = CASE
                                    WHEN [MtContractRegistration_MeterOwner] = 'Buyer' THEN
                                        [MtContractRegistration_BuyerId]
                                    WHEN [MtContractRegistration_MeterOwner] = 'Seller' THEN
                                        [MtContractRegistration_SellerId]
                                END,
               @vPartyCategoryId = CASE
                                       WHEN [MtContractRegistration_MeterOwner] = 'Buyer' THEN
                                           [MtContractRegistration_BuyerCategoryId]
                                       WHEN [MtContractRegistration_MeterOwner] = 'Seller' THEN
                                           [MtContractRegistration_SellerCategoryId]
                                   END
        FROM [dbo].[MtContractRegistration]
        WHERE [MtContractRegistration_Id] = @pBilateralContractId
              AND ISNULL([MtContractRegistration_IsDeleted], 0) = 0;

        --- 2. Get the relevant information based on the meter owner ID and the Party Category ID 


        DROP TABLE IF EXISTS #tempRuCDPDetails

        SELECT rc.RuCDPDetail_Id,
               rc.RuCDPDetail_CdpId,
               rc.RuCDPDetail_CdpName,
               rc.RuCDPDetail_Station,
               rc.RuCDPDetail_FromCustomer,
               rc.RuCDPDetail_ToCustomer,
               0 AS CdpTP_IsTradingEnabled
        INTO #tempRuCDPDetails
        FROM RuCDPDetail rc
        WHERE (
                  rc.RuCDPDetail_ConnectedFromID = @vMeterOwnerId
                  OR rc.RuCDPDetail_ConnectedToID = @vMeterOwnerId
              )
              AND (
                      rc.RuCDPDetail_ConnectedToCategoryID = @vPartyCategoryId
                      OR rc.RuCDPDetail_ConnectedFromCategoryID = @vPartyCategoryId
                  )





        UPDATE t
        SET CdpTP_IsTradingEnabled = 1
        From #tempRuCDPDetails t
        WHERE t.RuCDPDetail_Id in (
                                      SELECT mctc.RuCDPDetail_Id
                                      FROM MtContractTradingCDPs mctc
                                      WHERE mctc.MtContractRegistration_Id = @pBilateralContractId
                                            AND ISNULL(mctc.MtContractTradingCDPs_IsDeleted, 0) = 0
                                  );

        SELECT *
        FROM #tempRuCDPDetails;



    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber,
               ERROR_STATE() AS ErrorState,
               ERROR_SEVERITY() AS ErrorSeverity,
               ERROR_PROCEDURE() AS ErrorProcedure,
               ERROR_LINE() AS ErrorLine,
               ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END
