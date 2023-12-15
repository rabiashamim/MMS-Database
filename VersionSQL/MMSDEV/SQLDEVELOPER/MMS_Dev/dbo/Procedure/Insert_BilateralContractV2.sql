/****** Object:  Procedure [dbo].[Insert_BilateralContractV2]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE    PROCEDURE dbo.Insert_BilateralContractV2              
  @fileMasterId decimal(18,0)          
 ,@UserId Int    
 , @pIsUseForSettlement bit =NULL
               
AS              
BEGIN  
SET NOCOUNT ON;  
              
 declare @vMtBilateralContract_Id Decimal(18,0);  
  
SELECT  
 @vMtBilateralContract_Id = ISNULL(MAX(MtBilateralContract_Id), 0) + 1  
FROM MtBilateralContract  
  
  
  
INSERT INTO MtBilateralContract (MtBilateralContract_RowNumber  
, MtBilateralContract_Id  
, MtSOFileMaster_Id  
, MtBilateralContract_Date  
, MtBilateralContract_Hour  
, MtBilateralContract_ContractId  
, MtBilateralContract_SellerMPId  
, MtBilateralContract_BuyerMPId  
, MtBilateralContract_ContractType  
, MtBilateralContract_MeterOwnerMPId  
, MtBilateralContract_CDPID  
, MtBilateralContract_Percentage  
, MtBilateralContract_ContractedQuantity  
, MtBilateralContract_CapQuantity  
, MtBilateralContract_AncillaryServices  
, MtBilateralContract_DistributionLosses  
, MtBilateralContract_TransmissionLoss  
, MtBilateralContract_CreatedBy  
, MtBilateralContract_CreatedOn  
, MtBilateralContract_Deleted  
, SrContractType_Id  
, ContractSubType_Id  
, BuyerSrCategory_Code  
, SellerSrCategory_Code)  
 SELECT  
  MtBilateralContract_RowNumber  
    ,@vMtBilateralContract_Id + ROW_NUMBER() OVER (ORDER BY MtBilateralContract_Date) AS MtBilateralContract_Id  
    ,@fileMasterId  
    ,mbci.MtBilateralContract_Date  
    ,mbci.MtBilateralContract_Hour  
    ,mbci.MtBilateralContract_ContractId  
    ,mbci.MtBilateralContract_SellerMPId  
    ,MtBilateralContract_BuyerMPId  
    ,MtBilateralContract_ContractType  
    ,MtBilateralContract_MeterOwnerMPId  
    ,MtBilateralContract_CDPID  
    ,MtBilateralContract_Percentage  
    ,MtBilateralContract_ContractedQuantity  
    ,MtBilateralContract_CapQuantity  
    ,MtBilateralContract_AncillaryServices  
    ,mbci.MtBilateralContract_DistributionLosses  
    ,mbci.MtBilateralContract_TransmissionLoss  
    ,@UserId  
    ,GETUTCDATE()  
    ,0  
    ,CASE  
   WHEN MtBilateralContract_ContractType IN ('Generation Following', 'Generation Following Supply Contract') THEN 1  
   WHEN MtBilateralContract_ContractType IN ('Load Following', 'Load Following Supply Contract') THEN 2  
   WHEN MtBilateralContract_ContractType IN ('Fixed Quantity', 'Financial Supply Contract with Fixed Quantities') THEN 3  
   WHEN MtBilateralContract_ContractType IN ('Customized', 'Customized Contract') THEN 4  
   WHEN MtBilateralContract_ContractType = 'Capacity and Associated Energy Supply Contract' THEN 5  
  END  
    ,CASE  
   WHEN MtBilateralContract_ContractType IN ('Load Following', 'Load Following Supply Contract') AND  
    (ISNULL(MtBilateralContract_DistributionLosses, '') <> '') AND  
    (ISNULL(MtBilateralContract_TransmissionLoss, '') = '') THEN 23  
   WHEN MtBilateralContract_ContractType IN ('Load Following', 'Load Following Supply Contract') AND  
    (ISNULL(MtBilateralContract_DistributionLosses, '') = '') AND  
    (ISNULL(MtBilateralContract_TransmissionLoss, '') <> '') THEN 22  
   WHEN MtBilateralContract_ContractType IN ('Load Following', 'Load Following Supply Contract') AND  
    (ISNULL(MtBilateralContract_DistributionLosses, '') = '') AND  
    (ISNULL(MtBilateralContract_TransmissionLoss, '') = '') THEN 21  
	   WHEN MtBilateralContract_ContractType IN ('Load Following', 'Load Following Supply Contract') AND  
    (ISNULL(MtBilateralContract_DistributionLosses, '') <> '') AND  
    (ISNULL(MtBilateralContract_TransmissionLoss, '') <> '') THEN 21  
   WHEN MtBilateralContract_ContractType IN ('Customized', 'Customized Contract') AND  
    ISNULL(MtBilateralContract_DistributionLosses, '') <> '' AND  
    ISNULL(MtBilateralContract_TransmissionLoss, '') <> '' THEN 41  
   WHEN MtBilateralContract_ContractType IN ('Customized', 'Customized Contract') AND  
    ((ISNULL(MtBilateralContract_DistributionLosses, '') = '') OR  
    (ISNULL(MtBilateralContract_TransmissionLoss, '') = '')) THEN 42  
   WHEN MtBilateralContract_ContractType IN ('Fixed Quantity', 'Financial Supply Contract with Fixed Quantities') OR  
    MtBilateralContract_ContractType IN ('Generation Following', 'Generation Following Supply Contract') THEN 0  
  END  
    ,BuyerSrCategory_Code  
    ,SellerSrCategory_Code  
 FROM MtBilateralContract_Interface mbci  
 WHERE mbci.MtSOFileMaster_Id = @fileMasterId;  
  
  
UPDATE MtSOFileMaster  
SET LuStatus_Code = 'DRAF'  
WHERE MtSOFileMaster_Id = @fileMasterId  
------------------------------------------  
DECLARE @version INT = 0;  
SELECT  
 @version = MtSOFileMaster_Version  
FROM MtSOFileMaster  
WHERE MtSOFileMaster_Id = @fileMasterId  
  
DECLARE @period INT = 0;  
SELECT  
 @period = LuAccountingMonth_Id  
FROM MtSOFileMaster  
WHERE MtSOFileMaster_Id = @fileMasterId  
  
DECLARE @pSOFileTemplate INT = 0;  
SELECT  
 @pSOFileTemplate = LuSOFileTemplate_Id  
FROM MtSOFileMaster  
WHERE MtSOFileMaster_Id = @fileMasterId  
  
DECLARE @tempname NVARCHAR(MAX) = NULL;  
SELECT  
 @tempname = LuSOFileTemplate_Name  
FROM LuSOFileTemplate  
WHERE LuSOFileTemplate_Id = @pSOFileTemplate  
  
--DECLARE @output VARCHAR(MAX);  
--DECLARE @pSettlementPeriodId VARCHAR(20);  
--SET @pSettlementPeriodId = [dbo].[GetSettlementMonthYear](@period)  
--SET @output = @tempname + 'submitted for approval. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ',Version:' + CONVERT(VARCHAR(MAX), @version)  
  
--EXEC [dbo].[SystemLogs] @user = @UserId  
--        ,@moduleName = 'Data Management'  
--        ,@CrudOperationName = 'Create'  
--        ,@logMessage = @output  
  
DELETE FROM MtBilateralContract_Interface  
WHERE MtSOFileMaster_Id = @fileMasterId;  
  
---------update of settlement flag-----  
UPDATE MtSOFileMaster  
SET MtSOFileMaster_IsUseForSettlement = 1--@pIsUseForSettlement  --Ammama: This is temporary. To avoid fresh deployment at this point to UAT.
WHERE MtSOFileMaster_Id = @fileMasterId;  
  
-----------sett log-----  
  
--SET @output = 'Use for Settlement Enabled for Dataset: ' + @tempname + '. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ',Version:' + CONVERT(VARCHAR(MAX), @version)  
  
--EXEC [dbo].[SystemLogs] @user = @UserId  
--        ,@moduleName = 'Data Management'  
--        ,@CrudOperationName = 'Update'  
--        ,@logMessage = @output  
END  
  
  
----------------------- 
