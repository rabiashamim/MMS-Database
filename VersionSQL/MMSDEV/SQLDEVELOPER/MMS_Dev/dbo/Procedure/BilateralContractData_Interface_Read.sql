/****** Object:  Procedure [dbo].[BilateralContractData_Interface_Read]    Committed by VersionSQL https://www.versionsql.com ******/

    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
    
    
    
    
    
    
    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
    
    
    
    
    
---Author: Ammama Gill              
    
--exec BilateralContractData_Interface_Read_Temp 625,1,10, 'MtBilateralContract_ContractId',1101                  
CREATE PROCEDURE dbo.BilateralContractData_Interface_Read @pMtSOFileMaster_Id DECIMAL(18, 0)    
, @pPageNumber INT = NULL    
, @pPageSize INT = NULL    
--, @pColumnName NVARCHAR(MAX) = NULL              
    
, @pMtBilateralContract_Date NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_Hour NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_ContractId NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_SellerMPId NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_BuyerMPId NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_ContractType NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_MeterOwnerMPId NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_CDPID NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_Percentage NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_ContractedQuantity NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_CapQuantity NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_AncillaryServices NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_DistributionLosses NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_TransmissionLoss NVARCHAR(MAX) = NULL    
, @pBuyerSrCategory_Code NVARCHAR(MAX) = NULL    
, @pSellerSrCategory_Code NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_Message NVARCHAR(MAX) = NULL    
, @pMtBilateralContract_IsValid NVARCHAR(10) = NULL    
, @pSrContractSubType_Name NVARCHAR(MAX) = NULL    
, @pfilterOperator NVARCHAR(MAX) = NULL    
    
AS    
BEGIN    
    
 DROP TABLE IF EXISTS #temp_BilateralContract_Interface    
 DROP TABLE IF EXISTS #temp_BilateralContract    
 DECLARE @vStatus VARCHAR(5);    
 SELECT    
  @vStatus = LuStatus_Code    
 FROM MtSOFileMaster    
 WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id;    
    
    
 IF (@vStatus = 'UPL'    
  OR @vStatus = 'GENE')    
 BEGIN    
    
    
  SELECT    
   ROW_NUMBER() OVER (ORDER BY MtBilateralContract_IsValid, mbci.MtBilateralContract_Date, MtBilateralContract_RowNumber) AS MtBilateralContract_RowNumber_new    
     ,MtBilateralContract_Id    
     ,MtSOFileMaster_Id    
     ,MtBilateralContract_RowNumber    
     ,CASE    
    WHEN ISDATE(MtBilateralContract_Date) = 1 THEN CONVERT(VARCHAR, MtBilateralContract_Date, 23)    
    ELSE MtBilateralContract_Date    
   END AS MtBilateralContract_Date    
     ,MtBilateralContract_Hour    
     ,MtBilateralContract_ContractId    
     ,MtBilateralContract_SellerMPId    
     ,MtBilateralContract_BuyerMPId    
     ,MtBilateralContract_ContractType    
     ,MtBilateralContract_MeterOwnerMPId    
     ,MtBilateralContract_CDPID    
     ,MtBilateralContract_Percentage    
     ,MtBilateralContract_ContractedQuantity    
     ,MtBilateralContract_CapQuantity    
     ,MtBilateralContract_AncillaryServices    
     ,MtBilateralContract_DistributionLosses    
     ,MtBilateralContract_TransmissionLoss    
     ,MtBilateralContract_CreatedBy    
     ,MtBilateralContract_CreatedOn    
     ,MtBilateralContract_ModifiedBy    
     ,MtBilateralContract_ModifiedOn    
     ,MtBilateralContract_Deleted    
     ,SrContractType_Id    
     ,ContractSubType_Id    
     ,BmeStatementData_NtdcDateTime    
     ,(SELECT    
     SrCategory_Name    
    FROM SrCategory    
    WHERE SrCategory_Code = BuyerSrCategory_Code)    
   AS BuyerSrCategory_Code    
     ,(SELECT    
     SrCategory_Name    
    FROM SrCategory    
    WHERE SrCategory_Code = SellerSrCategory_Code)    
   AS SellerSrCategory_Code    
     ,RuCDPDetail_CongestedZoneID    
     ,RuCDPDetail_TaxZoneID    
     ,MtBilateralContract_Message    
     ,MtBilateralContract_IsValid    
     ,(SELECT    
     ssct.SrSubContractType_Name    
    FROM SrSubContractType ssct    
    WHERE ssct.SrSubContractType = mbci.ContractSubType_Id)    
   AS SrContractSubType_Name INTO #temp_BilateralContract_Interface    
  FROM MtBilateralContract_Interface mbci    
    
  WHERE ISNULL(mbci.MtBilateralContract_Deleted, 0) = 0    
  AND mbci.MtSOFileMaster_Id = @pMtSOFileMaster_Id    
  AND (@pMtBilateralContract_Date IS NULL    
  OR CONVERT(VARCHAR(10), mbci.MtBilateralContract_Date, 103) = CONVERT(DATE, @pMtBilateralContract_Date, 101))    
  AND (@pMtBilateralContract_Hour IS NULL    
  OR mbci.MtBilateralContract_Hour = @pMtBilateralContract_Hour)    
  AND (@pMtBilateralContract_ContractId IS NULL    
  OR mbci.MtBilateralContract_ContractId = @pMtBilateralContract_ContractId)    
  AND (@pMtBilateralContract_SellerMPId IS NULL    
  OR mbci.MtBilateralContract_SellerMPId = @pMtBilateralContract_SellerMPId)    
  AND (@pMtBilateralContract_BuyerMPId IS NULL    
  OR mbci.MtBilateralContract_BuyerMPId = @pMtBilateralContract_BuyerMPId)    
  AND (@pMtBilateralContract_ContractType IS NULL    
  OR mbci.MtBilateralContract_ContractType LIKE ('%' + @pMtBilateralContract_ContractType + '%'))    
  AND (@pMtBilateralContract_MeterOwnerMPId IS NULL    
  OR mbci.MtBilateralContract_MeterOwnerMPId = @pMtBilateralContract_MeterOwnerMPId)    
  AND (@pMtBilateralContract_CDPID IS NULL    
  OR mbci.MtBilateralContract_CDPID = @pMtBilateralContract_CDPID)    
  AND (@pMtBilateralContract_Percentage IS NULL    
  OR mbci.MtBilateralContract_Percentage = @pMtBilateralContract_Percentage)    
  AND (@pMtBilateralContract_ContractedQuantity IS NULL    
  OR ISNULL(MtBilateralContract_ContractedQuantity, 0) = @pMtBilateralContract_ContractedQuantity)    
  AND (@pMtBilateralContract_CapQuantity IS NULL    
  OR ISNULL(MtBilateralContract_CapQuantity, 0) = @pMtBilateralContract_CapQuantity)    
  AND (@pMtBilateralContract_AncillaryServices IS NULL    
  OR mbci.MtBilateralContract_AncillaryServices LIKE ('%' + @pMtBilateralContract_AncillaryServices + '%'))    
  AND (@pMtBilateralContract_DistributionLosses IS NULL    
  OR mbci.MtBilateralContract_DistributionLosses LIKE ('%' + @pMtBilateralContract_DistributionLosses + '%'))    
  AND (@pMtBilateralContract_TransmissionLoss IS NULL    
  OR mbci.MtBilateralContract_TransmissionLoss LIKE ('%' + @pMtBilateralContract_TransmissionLoss + '%'))    
  AND (@pBuyerSrCategory_Code IS NULL    
  OR mbci.BuyerSrCategory_Code LIKE ('%' + @pBuyerSrCategory_Code + '%'))    
  AND (@pSellerSrCategory_Code IS NULL    
  OR mbci.SellerSrCategory_Code LIKE ('%' + @pSellerSrCategory_Code + '%'))    
  AND (@pMtBilateralContract_Message IS NULL    
  OR mbci.MtBilateralContract_Message LIKE ('%' + @pMtBilateralContract_Message + '%'))    
  AND (@pMtBilateralContract_IsValid IS NULL    
  OR mbci.MtBilateralContract_IsValid = @pMtBilateralContract_IsValid)    
  AND (@pSrContractSubType_Name IS NULL    
  OR (SELECT    
    ssct.SrSubContractType_Name    
   FROM SrSubContractType ssct    
   WHERE ssct.SrSubContractType = mbci.ContractSubType_Id)    
  LIKE ('%' + @pSrContractSubType_Name + '%'))    
  --ORDER BY MtBilateralContract_RowNumber asc              
    
    
  IF @pPageNumber IS NULL    
   AND @pPageSize IS NULL    
  BEGIN    
   SELECT    
   -- FORMAT(CAST(tbci.MtBilateralContract_Date AS DATE) , 'dd-MM-yyyy') AS [DATE] 
   MtBilateralContract_Date AS [DATE]
      ,tbci.MtBilateralContract_Hour AS [Hour]    
      ,tbci.MtBilateralContract_ContractId AS [Contract ID]    
      ,tbci.MtBilateralContract_SellerMPId AS [ Seller MP ID]    
      ,tbci.MtBilateralContract_BuyerMPId AS [Buyer MP ID]    
      ,tbci.MtBilateralContract_ContractType AS [Contract Type]    
      ,tbci.MtBilateralContract_MeterOwnerMPId AS [Meter Owner MP ID]    
      ,tbci.MtBilateralContract_CDPID AS [CDP ID]    
      ,tbci.MtBilateralContract_Percentage AS [Percentage]    
      ,tbci.MtBilateralContract_ContractedQuantity AS [Contracted Quantity (kWh)]    
      ,tbci.MtBilateralContract_CapQuantity AS [Cap Quantity (kWh)]    
      ,tbci.MtBilateralContract_AncillaryServices AS [Ancillary Services]    
      ,tbci.MtBilateralContract_DistributionLosses AS [Distribution Losses]    
      ,tbci.MtBilateralContract_TransmissionLoss AS [Transmission Losses]    
      ,tbci.BuyerSrCategory_Code AS [Buyer Category Code]    
      ,tbci.SellerSrCategory_Code AS [Seller Category Code]    
      ,CASE WHEN MtBilateralContract_IsValid = 1 THEN 'Valid' ELSE 'Invalid' END AS [Is Valid]    
      ,MtBilateralContract_Message AS [Message]    
    
    
   FROM #temp_BilateralContract_Interface tbci    
   ORDER BY tbci.MtBilateralContract_RowNumber_new ASC    
  END    
  ELSE    
  BEGIN    
    
   SELECT    
    *    
   FROM #temp_BilateralContract_Interface tbci    
   WHERE (MtBilateralContract_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)    
   AND MtBilateralContract_RowNumber_new <= (@pPageNumber * @pPageSize))    
   ORDER BY MtBilateralContract_RowNumber_new ASC    
    
    
    
   --END              
    
   SELECT    
    COUNT(1) AS FilteredRows    
   FROM #temp_BilateralContract_Interface mbci    
   WHERE mbci.MtSOFileMaster_Id = @pMtSOFileMaster_Id    
   AND mbci.MtBilateralContract_Deleted = 0    
  END    
    
 END    
    
    
 ELSE    
 BEGIN    
    
    
  SELECT    
   ROW_NUMBER() OVER (ORDER BY mbci.MtBilateralContract_Id) AS MtBilateralContract_RowNumber_new    
     ,(SELECT    
     ssct.SrSubContractType_Name    
    FROM SrSubContractType ssct    
    WHERE ssct.SrSubContractType = mbci.ContractSubType_Id)    
   AS SrContractSubType_Name    
     ,MtBilateralContract_Id    
     ,MtSOFileMaster_Id    
     ,MtBilateralContract_Date    
     ,MtBilateralContract_Hour    
     ,MtBilateralContract_ContractId    
     ,MtBilateralContract_SellerMPId    
     ,MtBilateralContract_BuyerMPId    
     ,MtBilateralContract_ContractType    
     ,MtBilateralContract_MeterOwnerMPId    
     ,MtBilateralContract_CDPID    
     ,MtBilateralContract_Percentage    
     ,MtBilateralContract_ContractedQuantity    
     ,MtBilateralContract_CapQuantity    
     ,MtBilateralContract_AncillaryServices    
     ,MtBilateralContract_DistributionLosses    
     ,MtBilateralContract_TransmissionLoss    
     ,MtBilateralContract_CreatedBy    
     ,MtBilateralContract_CreatedOn    
     ,MtBilateralContract_ModifiedBy    
     ,MtBilateralContract_ModifiedOn    
     ,MtBilateralContract_Deleted    
     ,SrContractType_Id    
     ,ContractSubType_Id    
     ,BmeStatementData_NtdcDateTime    
   --,BuyerSrCategory_Code        
   --,SellerSrCategory_Code        
     ,(SELECT    
     SrCategory_Name    
    FROM SrCategory    
    WHERE SrCategory_Code = BuyerSrCategory_Code)    
   AS BuyerSrCategory_Code    
     ,(SELECT    
     SrCategory_Name    
    FROM SrCategory    
    WHERE SrCategory_Code = SellerSrCategory_Code)    
   AS SellerSrCategory_Code    
    
     ,RuCDPDetail_CongestedZoneID    
     ,RuCDPDetail_TaxZoneID INTO #temp_BilateralContract    
  FROM MtBilateralContract mbci    
  WHERE ISNULL(mbci.MtBilateralContract_Deleted, 0) = 0    
  AND mbci.MtSOFileMaster_Id = @pMtSOFileMaster_Id    
  AND (@pMtBilateralContract_Date IS NULL    
  OR mbci.MtBilateralContract_Date = CONVERT(DATE, @pMtBilateralContract_Date, 101))
  --CONVERT(VARCHAR(10), mbci.MtBilateralContract_Date, 103) = CONVERT(DATE, @pMtBilateralContract_Date, 101))    
  AND (@pMtBilateralContract_Hour IS NULL    
  OR mbci.MtBilateralContract_Hour = @pMtBilateralContract_Hour)    
  AND (@pMtBilateralContract_ContractId IS NULL    
  OR mbci.MtBilateralContract_ContractId = @pMtBilateralContract_ContractId)    
  AND (@pMtBilateralContract_SellerMPId IS NULL    
  OR mbci.MtBilateralContract_SellerMPId = @pMtBilateralContract_SellerMPId)    
  AND (@pMtBilateralContract_BuyerMPId IS NULL    
  OR mbci.MtBilateralContract_BuyerMPId = @pMtBilateralContract_BuyerMPId)    
  AND (@pMtBilateralContract_ContractType IS NULL    
  OR mbci.MtBilateralContract_ContractType LIKE ('%' + @pMtBilateralContract_ContractType + '%'))    
  AND (@pMtBilateralContract_MeterOwnerMPId IS NULL    
  OR mbci.MtBilateralContract_MeterOwnerMPId = @pMtBilateralContract_MeterOwnerMPId)    
  AND (@pMtBilateralContract_CDPID IS NULL    
  OR mbci.MtBilateralContract_CDPID = @pMtBilateralContract_CDPID)    
  AND (@pMtBilateralContract_Percentage IS NULL    
  OR mbci.MtBilateralContract_Percentage = @pMtBilateralContract_Percentage)    
  AND (@pMtBilateralContract_ContractedQuantity IS NULL    
  OR ISNULL(MtBilateralContract_ContractedQuantity, 0) = @pMtBilateralContract_ContractedQuantity)    
  AND (@pMtBilateralContract_CapQuantity IS NULL    
  OR ISNULL(MtBilateralContract_CapQuantity, 0) = @pMtBilateralContract_CapQuantity)    
  AND (@pMtBilateralContract_AncillaryServices IS NULL    
  OR mbci.MtBilateralContract_AncillaryServices LIKE ('%' + @pMtBilateralContract_AncillaryServices + '%'))    
  AND (@pMtBilateralContract_DistributionLosses IS NULL    
  OR mbci.MtBilateralContract_DistributionLosses LIKE ('%' + @pMtBilateralContract_DistributionLosses + '%'))    
  AND (@pMtBilateralContract_TransmissionLoss IS NULL    
  OR mbci.MtBilateralContract_TransmissionLoss LIKE ('%' + @pMtBilateralContract_TransmissionLoss + '%'))    
  AND (@pBuyerSrCategory_Code IS NULL    
  OR mbci.BuyerSrCategory_Code LIKE ('%' + @pBuyerSrCategory_Code + '%'))    
  AND (@pSellerSrCategory_Code IS NULL    
  OR mbci.SellerSrCategory_Code LIKE ('%' + @pSellerSrCategory_Code + '%'))    
  AND (@pSrContractSubType_Name IS NULL    
  OR (SELECT    
    ssct.SrSubContractType_Name    
   FROM SrSubContractType ssct    
   WHERE ssct.SrSubContractType = mbci.ContractSubType_Id)    
  LIKE ('%' + @pSrContractSubType_Name + '%'))    
    
  --ORDER BY MtBilateralContract_RowNumber asc                 
    
    
  IF @pPageNumber IS NULL    
   AND @pPageSize IS NULL    
  BEGIN    
   SELECT    
    --FORMAT(tbc.MtBilateralContract_Date , 'dd-MM-yyyy') AS [DATE]   
	tbc.MtBilateralContract_Date AS [DATE]
      ,tbc.MtBilateralContract_Hour AS [Hour]    
      ,tbc.MtBilateralContract_ContractId AS [Contract ID]    
      ,tbc.MtBilateralContract_SellerMPId AS [ Seller MP ID]    
      ,tbc.MtBilateralContract_BuyerMPId AS [Buyer MP ID]    
      ,tbc.MtBilateralContract_ContractType AS [Contract Type]    
      ,tbc.MtBilateralContract_MeterOwnerMPId AS [Meter Owner MP ID]    
      ,tbc.MtBilateralContract_CDPID AS [CDP ID]    
      ,tbc.MtBilateralContract_Percentage AS [Percentage]    
      ,tbc.MtBilateralContract_ContractedQuantity AS [Contracted Quantity (kWh)]    
      ,tbc.MtBilateralContract_CapQuantity AS [Cap Quantity (kWh)]    
      ,tbc.MtBilateralContract_AncillaryServices AS [Ancillary Services]    
      ,tbc.MtBilateralContract_DistributionLosses AS [Distribution Losses]    
      ,tbc.MtBilateralContract_TransmissionLoss AS [Transmission Losses]    
      ,tbc.BuyerSrCategory_Code AS [Buyer Category Code]    
      ,tbc.SellerSrCategory_Code AS [Seller Category Code]    
   FROM #temp_BilateralContract tbc    
   ORDER BY tbc.MtBilateralContract_RowNumber_new ASC    
  END    
  ELSE    
  BEGIN    
   SELECT    
    *    
   FROM #temp_BilateralContract tbc    
   WHERE (MtBilateralContract_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)    
   AND MtBilateralContract_RowNumber_new <= (@pPageNumber * @pPageSize))    
   ORDER BY MtBilateralContract_RowNumber_new ASC    
    
    
    
    
   -- END              
    
    
   SELECT    
    COUNT(1) AS FilteredRows    
   FROM #temp_BilateralContract tbc    
   WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id    
   AND tbc.MtBilateralContract_Deleted = 0;    
  END    
    
 END    
    
 DROP TABLE IF EXISTS #temp_BilateralContract_Interface    
 DROP TABLE IF EXISTS #temp_BilateralContract    
    
    
END
