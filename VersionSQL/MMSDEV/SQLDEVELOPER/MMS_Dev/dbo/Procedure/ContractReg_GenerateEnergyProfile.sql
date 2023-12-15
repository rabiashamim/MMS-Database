/****** Object:  Procedure [dbo].[ContractReg_GenerateEnergyProfile]    Committed by VersionSQL https://www.versionsql.com ******/

-- ==========================================================================================        
-- Author:  ALI IMRAN  
-- CREATE date: Nov 28, 2022       
-- ALTER date:       
-- Reviewer:      
-- Description: Generate Energy profile of the given year and Master File ID.      
-- ==========================================================================================       
--SELECT * FROM MtSOFileMaster ORDER BY 1 desc  
--  dbo.ContractReg_GenerateEnergyProfile 2022,9,187,100  
CREATE PROCEDURE dbo.ContractReg_GenerateEnergyProfile (@pYear INT,  
@pMonth INT,  
@psoFileMasterId DECIMAL(18, 0),  
@pUserId INT)  
AS  
BEGIN  
  
 BEGIN TRY  
  
  --------------------------------------------  
  --DROP TABLE IF EXISTS #contracts  
  --DROP TABLE IF EXISTS #contractEP  
  --DROP TABLE IF EXISTS #TempHours  
  
  DECLARE @MONTH_EFFECTIVE_FROM AS DATETIME = DATETIMEFROMPARTS(@pYear, @pMonth, 1, 0, 0, 0, 0);  
  --DECLARE @MONTH_EFFECTIVE_TO AS DATETIME = DATEADD(MONTH, 1, @MONTH_EFFECTIVE_FROM);  
  DECLARE @MONTH_EFFECTIVE_TO AS DATETIME = EOMONTH(@MONTH_EFFECTIVE_FROM);  
  
  DECLARE @INC_Hour AS INT = 1;  
  DECLARE @MONTH_BVM_READING_START_TIME AS DATETIME = DATETIMEFROMPARTS(@pYear, @pMonth, 1, 0, 0, 0, 0);  
  DECLARE @MONTH_BVM_READING_END_TIME AS DATETIME = DATEADD(HOUR, -1, DATEADD(MONTH, 1, @MONTH_BVM_READING_START_TIME));  
  
  
  WITH ROWCTE  
  AS  
  (SELECT  
    @MONTH_BVM_READING_START_TIME AS dateTimeHour  
   UNION ALL  
   SELECT  
    DATEADD(HOUR, @INC_Hour, dateTimeHour)  
   FROM ROWCTE  
  
   WHERE dateTimeHour < @MONTH_BVM_READING_END_TIME)  
  
  SELECT  
   * INTO #TempHours  
  FROM ROWCTE  
  OPTION (MAXRECURSION 0)  
  
  
  ---------------------------------------------------  
  
  
  
  SELECT  
   * INTO #contracts  
  FROM MtContractRegistration  
  WHERE   
  (@MONTH_EFFECTIVE_FROM >= MtContractRegistration_EffectiveFrom  
  OR  MtContractRegistration_EffectiveFrom  BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO  
  )  
   
  AND (@MONTH_EFFECTIVE_TO <= MtContractRegistration_EffectiveTo  
  OR  MtContractRegistration_EffectiveTo  BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO  
  )  
  AND MtContractRegistration_IsDeleted = 0  
  AND MtContractRegistration_Status='CATV' --only active contract  
AND MtContractRegistration_ApprovalStatus IN ('CAAP','CAMA','CAWA')  
  IF NOT EXISTS (SELECT  
     1  
    FROM #contracts)  
  BEGIN  
    --PRINT ('NOT Contract founds')  
             RAISERROR('No Contract found to Generate Energy Profile.', 16, -1)        
    RETURN;  
  END  
  
  ---------------------------------------------------------------------  
  SELECT  
   rc.RuCDPDetail_CdpId AS CDPID  
     ,(SELECT TOP 1  
     SrCategory_Code  
    FROM MtPartyCategory  
    WHERE MtPartyCategory_Id = c.MtContractRegistration_BuyerCategoryId  
    AND ISNULL(isDeleted, 0) = 0)  
   AS BuyerSrCategory_Code  
     ,(SELECT TOP 1  
     SrCategory_Code  
    FROM MtPartyCategory  
    WHERE MtPartyCategory_Id = c.MtContractRegistration_SellerCategoryId  
    AND ISNULL(isDeleted, 0) = 0)  
   AS SellerSrCategory_Code  
     ,c.MtContractRegistration_SellerCategoryId  
     ,c.MtContractRegistration_Id AS ContractId  
     ,c.MtContractRegistration_SellerId AS SellerMPId  
     ,c.MtContractRegistration_BuyerId AS BuyerMPId  
     ,CT.SrContractType_Name AS ContractType  
     ,CASE  
    WHEN c.MtContractRegistration_MeterOwner = 'Buyer' THEN MtContractRegistration_BuyerId  
    ELSE MtContractRegistration_SellerId  
   END AS MeterOwnerMPId  
     ,CPE.MtContractProfileEnergy_Percentage AS Percentages  
     ,CPE.MtContractProfileEnergy_ContractQuantity_KWH AS ContractedQuantity  
     ,CPE.MtContractProfileEnergy_CapQuantity_KWH AS CapQuantity  
     ,c.MtContractRegistration_AncillaryService AS AncillaryServices  
     ,c.MtContractRegistration_DistributionLosses AS DistributionLosses  
     ,c.MtContractRegistration_TransmissionLosses AS TransmissionLoss  
     ,CPE.MtContractProfileEnergy_DateFrom  
     ,CPE.MtContractProfileEnergy_DateTo  
     ,CPE.MtContractProfileEnergy_HourFrom  
     ,CPE.MtContractProfileEnergy_HourTo INTO #contractEP  
  FROM [dbo].[MtContractProfileEnergy] CPE  
  JOIN #contracts c  
   ON c.MtContractRegistration_Id = CPE.MtContractRegistration_Id  
  JOIN MtContractTradingCDPs CTP  
   ON CTP.MtContractRegistration_Id = c.MtContractRegistration_Id  
  JOIN RuCDPDetail rc  
   ON rc.RuCDPDetail_Id = CTP.RuCDPDetail_Id  
  JOIN SrContractType CT  
   ON CT.SrContractType_Id = c.SrContractType_Id  
  WHERE CPE.MtContractProfileEnergy_IsDeleted = 0  
  AND CTP.MtContractTradingCDPs_IsDeleted = 0  
  
  
  
  DECLARE @typeBilateralContract MtBilateralContract_UDT_Interface  
  INSERT INTO @typeBilateralContract ([MtBilateralContract_Date]  
  , [MtBilateralContract_Hour]  
  , [MtBilateralContract_ContractId]  
  , [MtBilateralContract_SellerMPId]  
  , [MtBilateralContract_BuyerMPId]  
  , [MtBilateralContract_ContractType]  
  , [MtBilateralContract_MeterOwnerMPId]  
  , [MtBilateralContract_CDPID]  
  , [MtBilateralContract_Percentage]  
  , [MtBilateralContract_ContractedQuantity]  
  , [MtBilateralContract_CapQuantity]  
  , [MtBilateralContract_AncillaryServices]  
  , [MtBilateralContract_DistributionLosses]  
  , [MtBilateralContract_TransmissionLoss]  
  , [BuyerSrCategory_Code]  
  , [SellerSrCategory_Code])  
   SELECT  
    CAST(th.dateTimeHour AS DATE) AS [Date]  
      ,DATEPART(HOUR, th.dateTimeHour) AS [Hours]  
      ,ContractId  
      ,SellerMPId  
      ,BuyerMPId  
      ,ContractType  
      ,MeterOwnerMPId  
      ,CDPID  
      ,Percentages  
      ,ContractedQuantity  
      ,CapQuantity  
      ,AncillaryServices  
      ,DistributionLosses  
      ,TransmissionLoss  
      ,BuyerSrCategory_Code  
      ,SellerSrCategory_Code  
  
   FROM #TempHours th  
    ,#contractEP CPE  
   WHERE CPE.MtContractProfileEnergy_DateFrom <= CAST(th.dateTimeHour AS DATE)  
   AND CPE.MtContractProfileEnergy_DateTo >= CAST(th.dateTimeHour AS DATE)  
   AND CPE.MtContractProfileEnergy_HourFrom <= DATEPART(HOUR, th.dateTimeHour)  
   AND CPE.MtContractProfileEnergy_HourTo >= DATEPART(HOUR, th.dateTimeHour)  
  
  
  
  
  EXEC [dbo].[Insert_BilateralContractData_Interface] @psoFileMasterId  
                 ,@pUserId  
                 ,@typeBilateralContract  
  
  
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
