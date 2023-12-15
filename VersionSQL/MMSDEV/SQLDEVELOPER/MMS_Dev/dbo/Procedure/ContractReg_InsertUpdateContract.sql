/****** Object:  Procedure [dbo].[ContractReg_InsertUpdateContract]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
          
            
CREATE   PROCEDUREdbo.ContractReg_InsertUpdateContract                  
 @pId INT=0                  
, @pSrContractType_Id INT                
,@pContractId as decimal(18,0)          
,@pSrSubContractType INT=0                  
,@pApplicationNubmer nvarchar(50)                  
,@pApplicationDate DATETIME                  
,@pBuyerId decimal(18,0)                  
,@pSellerId decimal(18,0)                  
,@pBuyerCategoryId decimal(18,0)                  
,@pSellerCategoryId decimal(18,0)                  
,@pTransmissionLosses nvarchar(6)                
,@pDistributionLosses nvarchar(6)                
,@pEffectiveFrom DATE                  
,@pEffectiveTo DATE                  
,@pContractDate DATE                  
,@pAncillaryService nvarchar(6)                  
,@pMeterOwner nvarchar(6)                  
,@user_id decimal(18,0)                  
As                  
BEGIN
                  
                
                  
--IF NOT EXISTS(SELECT top 1 1 FROM  [dbo].[MtContractRegistration] WHERE MtContractRegistration_ApplicationNubmer=@pApplicationNubmer) 


Declare @sellercode as varchar(4);
DEclare @buyercode as varchar(4);
SELECT
	@sellercode = SrCategory_Code
FROM MtPartyCategory
WHERE MtPartyCategory_Id = @pSellerCategoryId
SELECT
	@buyercode = SrCategory_Code
FROM MtPartyCategory
WHERE MtPartyCategory_Id = @pBuyerCategoryId

DECLARE @categoryCodeExist INT;

SELECT
	@categoryCodeExist = COUNT(*)
FROM LuAllowedContracts
WHERE LuAllowedContracts_SellerCode = @sellercode
AND LuAllowedContracts_BuyerCode = @buyercode;

IF (@categoryCodeExist = 0)
BEGIN

RAISERROR ('Contract is not allowed between the selected seller & buyer category', 16, -1);
RETURN;  
END

ELSE IF (@pId = 0)
BEGIN
INSERT INTO [dbo].[MtContractRegistration] ([MtContractRegistration_ContractId]
, [SrContractType_Id]
, [SrSubContractType]
, [MtContractRegistration_ApplicationNubmer]
, [MtContractRegistration_ApplicationDate]
, [MtContractRegistration_BuyerId]
, [MtContractRegistration_SellerId]
, [MtContractRegistration_BuyerCategoryId]
, [MtContractRegistration_SellerCategoryId]
, [MtContractRegistration_EffectiveFrom]
, [MtContractRegistration_EffectiveTo]
, [MtContractRegistration_ContractDate]
, [MtContractRegistration_AncillaryService]
, [MtContractRegistration_MeterOwner]
, [MtContractRegistration_TransmissionLosses]
, [MtContractRegistration_DistributionLosses]
, [MtContractRegistration_Status]
, [MtContractRegistration_ApprovalStatus]
, [MtContractRegistration_CreatedBy]
, [MtContractRegistration_CreatedOn]
, [MtContractRegistration_ModifiedBy]
, [MtContractRegistration_ModifiedOn]
, [MtContractRegistration_IsDeleted])

	VALUES (@pContractId, @pSrContractType_Id, NULLIF(@pSrSubContractType, 0), @pApplicationNubmer, @pApplicationDate, @pBuyerId, @pSellerId, @pBuyerCategoryId, @pSellerCategoryId, @pEffectiveFrom, @pEffectiveTo, @pContractDate, @pAncillaryService, @pMeterOwner, @pTransmissionLosses, @pDistributionLosses, 'CDRT' --Draft                  
	, 'CADR' --Draft                  
	, @user_id, GETDATE(), NULL, NULL, 0)

SELECT
	@@identity
DECLARE @output NVARCHAR(MAX);
SET @output = 'New Contract Created. Contract ID: ' + CONVERT(VARCHAR(MAX), @pContractId) + ', Seller ID: ' + CONVERT(VARCHAR(MAX), @pSellerId) + ', Buyer ID: ' + CONVERT(VARCHAR(MAX), @pBuyerId)



EXEC [dbo].[SystemLogs] @user = @user_id
					   ,@moduleName = 'Contract Registration'
					   ,@CrudOperationName = 'Create'
					   ,@logMessage = @output

END
ELSE
BEGIN

UPDATE [dbo].[MtContractRegistration]
SET --[SrContractType_Id] =@pSrContractType_Id                
--,[SrSubContractType] = @pSrSubContractType                
 [MtContractRegistration_ApplicationNubmer] = @pApplicationNubmer
,[MtContractRegistration_ApplicationDate] = @pApplicationDate
 --since buyer and seller id cannot be updated after initial insertion                
 --,[MtContractRegistration_BuyerId] = @pBuyerId                
 --,[MtContractRegistration_SellerId] = @pSellerId                
 --      ,[MtContractRegistration_BuyerCategoryId] = @pBuyerCategoryId                
 --      ,[MtContractRegistration_SellerCategoryId] = @pSellerCategoryId                
,[MtContractRegistration_EffectiveFrom] = @pEffectiveFrom
,[MtContractRegistration_EffectiveTo] = @pEffectiveTo
,[MtContractRegistration_ContractDate] = @pContractDate
,[MtContractRegistration_AncillaryService] = @pAncillaryService
,[MtContractRegistration_TransmissionLosses] = @pTransmissionLosses
,[MtContractRegistration_DistributionLosses] = @pDistributionLosses
 --,[MtContractRegistration_Status] = 'ADRF'                
 --,[MtContractRegistration_ApprovalStatus] = 'ADRF'                
,[MtContractRegistration_ModifiedBy] = @user_id
,[MtContractRegistration_ModifiedOn] = GETDATE()
--      ,[MtContractRegistration_MeterOwner] = @pMeterOwner                
WHERE MtContractRegistration_Id = @pId

SELECT
	@@rowcount
DECLARE @name VARCHAR(20);
SELECT
	@name = LuStatus_Name
FROM MtContractRegistration mcr
INNER JOIN LuStatus
	ON LuStatus.LuStatus_Code = mcr.MtContractRegistration_Status
WHERE mcr.MtContractRegistration_Id = @pId
DECLARE @logMessage1 VARCHAR(MAX)
SET @logMessage1 = 'Contract Updated. Contract ID: ' + CONVERT(VARCHAR(MAX), @pContractId) + ', Action Performed: ' + @name + ', Contract Status: Modify'
EXEC [dbo].[SystemLogs] @user = @user_id
					   ,@moduleName = 'Contract Registration'
					   ,@CrudOperationName = 'Update'
					   ,@logMessage = @logMessage1






--     select @@identity                  

--   RETURN @@identity                
END


END
