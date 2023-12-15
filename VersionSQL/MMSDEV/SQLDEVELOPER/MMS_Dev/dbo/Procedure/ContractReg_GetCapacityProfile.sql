/****** Object:  Procedure [dbo].[ContractReg_GetCapacityProfile]    Committed by VersionSQL https://www.versionsql.com ******/

  
-- =============================================                    
-- Author(s): Ammama Gill | Sadaf Malik              
-- CREATE date: Nov 28, 2022                   
-- ALTER date:                   
-- Reviewer:                  
-- Description:                   
-- =============================================                   
-- =============================================                   
--dbo.ContractReg_GetCapacityProfile 524,2,10              
  
CREATE PROCEDURE dbo.ContractReg_GetCapacityProfile (@psoFileMasterId DECIMAL(18, 0),  
@pPageSize INT = NULL,  
@pPageNumber INT = NULL,  
@pMtBilateralContract_ContractId DECIMAL(18, 0) = NULL,  
@pSellerName VARCHAR(250) = NULL,  
@pBuyerName VARCHAR(250) = NULL,  
@pMtBilateralContract_ContractType VARCHAR(50) = NULL,  
@pCapacityType VARCHAR(20) = NULL,  
@pBuyerSrCategory_Code VARCHAR(20) = NULL,  
@pSellerSrCategory_Code VARCHAR(20) = NULL,  
@pMtBilateralContract_BuyerMPId INT = NULL,  
@pMtBilateralContract_SellerMPId INT = NULL,  
@pMtBilateralContract_Date VARCHAR(MAX) = NULL)  
AS  
BEGIN  
  
 BEGIN TRY  
  
  IF EXISTS (SELECT  
     *  
    FROM MtSOFileMaster msm  
    WHERE msm.MtSOFileMaster_Id = @psoFileMasterId  
    AND ISNULL(msm.MtSOFileMaster_IsDeleted, 0) = 0)  
  BEGIN  
  
  
  
  
   SELECT  
    mbcc.MtBilateralContractCapacity_Date AS Date  
      ,mbcc.MtContractRegistration_Id AS [Contract ID]  
      ,mbcc.MtContractRegistration_BuyerId AS [Buyer ID]  
      ,mbcc.MtContractRegistration_SellerId AS [Seller ID]  
      ,(SELECT  
      mpr.MtPartyRegisteration_Name  
     FROM MtPartyRegisteration mpr  
     WHERE mpr.MtPartyRegisteration_Id = mbcc.MtContractRegistration_BuyerId  
     AND ISNULL(mpr.isDeleted, 0) = 0)  
    AS [Buyer]  
      ,(SELECT  
      mpr.MtPartyRegisteration_Name  
     FROM MtPartyRegisteration mpr  
     WHERE mpr.MtPartyRegisteration_Id = mbcc.MtContractRegistration_SellerId  
     AND ISNULL(mpr.isDeleted, 0) = 0)  
    AS [Seller]  
      ,mbcc.MtContractRegistration_BuyerCategoryId AS [Buyer Category ID]  
      ,mbcc.MtContractRegistration_SellerCategoryId AS [Seller Category ID]  
      ,(SELECT  
      mpc.SrCategory_Code  
     FROM MtPartyCategory mpc  
     WHERE mpc.MtPartyCategory_Id = mbcc.MtContractRegistration_BuyerCategoryId  
     AND ISNULL(mpc.isDeleted, 0) = 0)  
    AS [Buyer Category Code]  
      ,(SELECT  
      mpc.SrCategory_Code  
     FROM MtPartyCategory mpc  
     WHERE mpc.MtPartyCategory_Id = mbcc.MtContractRegistration_SellerCategoryId  
     AND ISNULL(mpc.isDeleted, 0) = 0)  
    AS [Seller Category Code]  
      ,sct.SrContractType_Name AS [Contract Type]  
      ,(CASE  
     WHEN mbcc.MtBilateralContractCapacity_IsGuarenteed = 0 THEN 'Non-Guaranteed'  
     ELSE 'Guaranteed'  
    END  
    ) AS [Capacity Type]  
      ,mbcc.MtBilateralContractCapacity_Percentage AS [Percentage]  
      ,mbcc.MtBilateralContractCapacity_ContractedQuantity AS [Contracted Capacity (MW)]  
      ,mbcc.MtBilateralContractCapacity_CapQuantity AS [Cap Quantity (MW)] INTO #tempBilateralContractCapacityInitial  
   FROM MtBilateralContractCapacity mbcc  
   INNER JOIN SrContractType sct  
    ON mbcc.SrContractType_Id = sct.SrContractType_Id  
   WHERE mbcc.MtSOFileMaster_Id = @psoFileMasterId  
   AND ISNULL(mbcc.MtBilateralContractCapacity_IsDeleted, 0) = 0  
  
   IF @pPageSize IS NULL  
    AND @pPageNumber IS NULL  
   BEGIN  
    SELECT  
     *  
    FROM #tempBilateralContractCapacityInitial bcci;  
   END  
   ELSE  
   BEGIN  
    SELECT  
     ROW_NUMBER() OVER (ORDER BY [Contract ID], [DATE]) AS MtBilateralContractCapacity_RowNumber  
       ,[DATE]  
       ,[Contract ID]  
       ,[Buyer ID]  
       ,[Seller ID]  
       ,[Buyer]  
       ,[Seller]  
       ,[Buyer Category ID]  
       ,[Seller Category ID]  
       ,[Buyer Category Code]  
       ,[Seller Category Code]  
       ,[Contract Type]  
       ,[Capacity Type]  
       ,[Percentage]  
       ,[Contracted Capacity (MW)]  
       ,[Cap Quantity (MW)] INTO #tempBilateralContractCapacityFiltered  
    FROM #tempBilateralContractCapacityInitial  
    WHERE (  
    @pMtBilateralContract_ContractId IS NULL  
    OR [Contract ID] = @pMtBilateralContract_ContractId  
    )  
    AND (  
    @pSellerName IS NULL  
    OR [Seller] LIKE ('%' + @pSellerName + '%')  
    )  
    AND (  
    @pBuyerName IS NULL  
    OR [Buyer] LIKE ('%' + @pBuyerName + '%')  
    )  
    AND (  
    @pMtBilateralContract_ContractType IS NULL  
    OR [Contract Type] LIKE ('%' + @pMtBilateralContract_ContractType + '%')  
    )  
    AND (  
    @pCapacityType IS NULL  
    OR [Capacity Type] LIKE ('%' + @pCapacityType + '%')  
    )  
    AND (  
    @pBuyerSrCategory_Code IS NULL  
    OR [Seller Category Code] LIKE ('%' + @pBuyerSrCategory_Code + '%')  
    )  
    AND (  
    @pSellerSrCategory_Code IS NULL  
    OR [Seller Category Code] LIKE ('%' + @pSellerSrCategory_Code + '%')  
    )  
    AND (  
    @pMtBilateralContract_BuyerMPId IS NULL  
    OR [Buyer ID] = @pMtBilateralContract_BuyerMPId  
    )  
    AND (  
    @pMtBilateralContract_SellerMPId IS NULL  
    OR [Seller ID] = @pMtBilateralContract_SellerMPId  
    )  
    AND (@pMtBilateralContract_Date IS NULL  
    OR CONVERT(VARCHAR(10), [DATE], 101) = @pMtBilateralContract_Date)  
  
    SELECT  
     *  
    FROM #tempBilateralContractCapacityFiltered  
    WHERE (  
    MtBilateralContractCapacity_RowNumber > ((@pPageNumber - 1) * @pPageSize)  
    AND MtBilateralContractCapacity_RowNumber <= (@pPageNumber * @pPageSize)  
    )  
    ORDER BY MtBilateralContractCapacity_RowNumber ASC  
  
    SELECT  
     COUNT(1) AS FilteredRows  
    FROM #tempBilateralContractCapacityFiltered;  
   END  
  
  END  
  
  
 END TRY  
 BEGIN CATCH  
  SELECT  
   ERROR_NUMBER() AS ErrorNumber  
     ,ERROR_STATE() AS ErrorState  
     ,ERROR_SEVERITY() AS ErrorSeverity  
     ,ERROR_PROCEDURE() AS ErrorProcedure  
     ,ERROR_LINE() AS ErrorLine  
     ,ERROR_MESSAGE() AS ErrorMessage;  
 END CATCH;  
END
