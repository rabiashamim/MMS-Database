/****** Object:  Procedure [dbo].[ContractReg_GetContractTradingCdps]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
-- =============================================            
-- Author:    Ammama Gill       
-- CREATE OR ALTER date: 15/11/2022          
-- ALTER date:             
    
-- Description:           
-- This SP returns the relevant CDP points for a registered contract.          
--          
    
-- Parameters: @pBilateralContractId          
-- =============================================           
-- [ContractReg_GetContractTradingCdps] 64         
CREATE   PROCEDURE dbo.ContractReg_GetContractTradingCdps 
(@pBilateralContractId decimal(18,0))    
AS    
BEGIN    
    BEGIN TRY    
    
        DECLARE @vCategoryCode VARCHAR(4),    
                @vPartyCategoryId INT;    
    
    
        --- 1. Get Meter Owner ID and party category ID.          
        SELECT    @vPartyCategoryId = CASE    
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
    
        SELECT DISTINCT rc.RuCDPDetail_Id,    
               rc.RuCDPDetail_CdpId,    
               rc.RuCDPDetail_CdpName,    
               rc.RuCDPDetail_Station,    
               rc.RuCDPDetail_FromCustomer,    
               rc.RuCDPDetail_ToCustomer,    
               0 AS CdpTP_IsTradingEnabled    
        INTO #tempRuCDPDetails    
        FROM RuCDPDetail rc    
  inner join MtConnectedMeter mcm on mcm.MtCDPDetail_Id=rc.RuCDPDetail_Id    
      WHERE     
  mcm.MtPartyCategory_Id=@vPartyCategoryId    
   OR rc.RuCDPDetail_Id in (Select RuCDPDetail_Id from MtContractTradingCDPs where MtContractRegistration_Id=@pBilateralContractId and MtContractTradingCDPs_IsDeleted=0)
  AND ISNULL(mcm.MtConnectedMeter_isDeleted,0)=0

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
        FROM #tempRuCDPDetails   ORDER BY CdpTP_IsTradingEnabled DESC;
  drop table #tempRuCDPDetails;
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
