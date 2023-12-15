/****** Object:  Procedure [dbo].[ContractReg_GetContractList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  Rabia Shamim  
-- CREATE date: Nov 15, 2022   
-- ALTER date:   
-- Reviewer:  
-- Description:   
-- ============================================= 
-- [ContractReg_GetContractList] 111

CREATE   PROCEDUREdbo.ContractReg_GetContractList -- 9--80                   
@pMtContractRegistration_Id DECIMAL(18, 0) = NULL --if id not given then show data in list only ,if header id is given then show detail data AS well                        
AS
	IF ISNULL(@pMtContractRegistration_Id, 0) = 0
	BEGIN


		SELECT
			MtContractRegistration_Id
		   ,MtContractRegistration_ContractId
		   ,C.SrContractType_Id
		   ,CT.SrContractType_Name
		   ,C.MtContractRegistration_BuyerId
		   ,(SELECT
					MtPartyRegisteration_Name
				FROM MtPartyRegisteration
				WHERE MtPartyRegisteration_Id = MtContractRegistration_BuyerId)
			Buyer_name
		   ,C.MtContractRegistration_SellerId
		   ,(SELECT
					MtPartyRegisteration_Name
				FROM MtPartyRegisteration
				WHERE MtPartyRegisteration_Id = MtContractRegistration_SellerId)
			Seller_name
		   ,MtContractRegistration_ContractDate
		   ,MtContractRegistration_EffectiveFrom
		   ,MtContractRegistration_EffectiveTo
		   ,(SELECT
					LuStatus_Name
				FROM LuStatus
				WHERE LuStatus_Code = C.MtContractRegistration_Status)
			AS MtContractRegistration_Status
		   ,(SELECT
					LuStatus_Name
				FROM LuStatus
				WHERE LuStatus_Code = C.MtContractRegistration_ApprovalStatus)
			AS MtContractRegistration_ApprovalStatus
		FROM MtContractRegistration C
		INNER JOIN SrContractType CT
			ON C.SrContractType_Id = CT.SrContractType_Id
		WHERE C.MtContractRegistration_IsDeleted = 0
		ORDER BY MtContractRegistration_Id DESC
	END
	ELSE
	BEGIN

		DECLARE @vIsLegacy BIT;
		SELECT
			@vIsLegacy =
			CASE
				WHEN MtContractRegistration_SellerId = 1 THEN 1  -- If seller is legacy generator, we deal with it separately.   
				ELSE 0
			END

		FROM MtContractRegistration CR
		WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
		SELECT
			MtContractRegistration_Id AS Id
		   ,C.SrContractType_Id AS ContractTypeId
		   ,C.MtContractRegistration_ApplicationNubmer AS ApplicationNumber
		   ,C.MtContractRegistration_ApplicationDate AS ApplicationDate
		   ,C.MtContractRegistration_DistributionLosses AS DistributionLosses
		   ,C.MtContractRegistration_TransmissionLosses AS TransmissionLosses
		   ,C.MtContractRegistration_ContractId AS ContractId
		   ,C.SrSubContractType AS SubContractTypeId
		   ,CT.SrContractType_Name AS ContractTypeName
		   ,C.MtContractRegistration_BuyerId AS BuyerId
		   ,C.MtContractRegistration_BuyerCategoryId AS BuyerCategoryId
		   ,(SELECT
					MtPartyRegisteration_Name
				FROM MtPartyRegisteration
				WHERE MtPartyRegisteration_Id = MtContractRegistration_BuyerId)
			AS BuyerName
		   ,C.MtContractRegistration_SellerId AS SellerId
		   ,C.MtContractRegistration_SellerCategoryId AS SellerCategoryId
		   ,(SELECT
					MtPartyRegisteration_Name
				FROM MtPartyRegisteration
				WHERE MtPartyRegisteration_Id = MtContractRegistration_SellerId)
			AS SellerName
		   ,MtContractRegistration_ContractDate AS ContractDate
		   ,MtContractRegistration_EffectiveFrom AS EffectiveFrom
		   ,MtContractRegistration_EffectiveTo AS EffectiveTo
		   ,MtContractRegistration_AncillaryService AS AncillaryServices
		   ,MtContractRegistration_MeterOwner AS MeterOwner
		   ,(SELECT
					LuStatus_Name
				FROM LuStatus
				WHERE LuStatus_Code = C.MtContractRegistration_Status)
			AS [Status]
		   ,C.MtContractRegistration_Status AS StatusCode
		   ,(SELECT
					LuStatus_Name
				FROM LuStatus
				WHERE LuStatus_Code = C.MtContractRegistration_ApprovalStatus)
			AS ApprovalStatus
		   ,C.MtContractRegistration_ApprovalStatus AS ApprovalStatusCode
		   ,@vIsLegacy AS IsLegacyContract
		FROM MtContractRegistration C
		INNER JOIN SrContractType CT
			ON C.SrContractType_Id = CT.SrContractType_Id
		WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
		AND C.MtContractRegistration_IsDeleted = 0
		ORDER BY MtContractRegistration_Id DESC
	END
