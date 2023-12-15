/****** Object:  Procedure [dbo].[BilateralContract_GetGeneratorList_bk12Jun23]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ammama Gill    
-- CREATE date: 07 June, 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
--[BilateralContract_GetGeneratorList] 130


create PROCEDURE dbo.BilateralContract_GetGeneratorList_bk12Jun23 (@pBilateralContractId DECIMAL(18, 0))
AS
BEGIN

	DECLARE @vSrCategory_Code VARCHAR(4)
	;
	SELECT
		@vSrCategory_Code = SrCategory_Code
	FROM MtContractRegistration CR
	INNER JOIN MtPartyCategory PC
		ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id
	WHERE CR.MtContractRegistration_Id = @pBilateralContractId;




	IF @vSrCategory_Code = 'GEN'
	BEGIN

		SELECT
			G.MtGenerator_Id AS GeneratorId
		   ,G.MtGenerator_Name AS GeneratorName
		FROM MtContractRegistration CR
		INNER JOIN MtPartyCategory PC
			ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id
		INNER JOIN MtGenerator G
			ON G.MtPartyCategory_Id = CR.MtContractRegistration_SellerCategoryId
		WHERE MtContractRegistration_Id = @pBilateralContractId
		AND ISNULL(MtContractRegistration_IsDeleted, 0) = 0
		AND ISNULL(G.isDeleted, 0) = 0
		AND ISNULL(MtGenerator_IsDeleted, 0) = 0
		AND ISNULL(PC.isDeleted, 0) = 0

	END

	ELSE
	BEGIN
		DROP TABLE IF EXISTS #ContractData;

		;
		WITH _cteRecursive
		AS
		(SELECT
				MtContractRegistration_Id
			   ,MtContractRegistration_SellerId
			   ,MtContractRegistration_SellerCategoryId
			   ,SrCategory_Code
			FROM MtContractRegistration CR
			INNER JOIN MtPartyCategory PC
				ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id
			WHERE MtContractRegistration_Id = @pBilateralContractId
			AND ISNULL(MtContractRegistration_IsDeleted, 0) = 0
			AND ISNULL(isDeleted, 0) = 0

			UNION ALL

			SELECT
				CR.MtContractRegistration_Id
			   ,CR.MtContractRegistration_SellerId
			   ,CR.MtContractRegistration_SellerCategoryId
			   ,PC.SrCategory_Code
			FROM _cteRecursive R
			INNER JOIN MtContractRegistration CR
				ON CR.MtContractRegistration_BuyerCategoryId = R.MtContractRegistration_SellerCategoryId
				AND CR.MtContractRegistration_BuyerId = R.MtContractRegistration_SellerId
			INNER JOIN MtPartyCategory PC
				ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id
			WHERE ISNULL(CR.MtContractRegistration_IsDeleted, 0) = 0
			AND ISNULL(PC.isDeleted, 0) = 0
		--AND MtContractRegistration_Status = 'CATV'

		)

		SELECT
			* INTO #ContractData
		FROM _cteRecursive
		OPTION (MAXRECURSION 0);

		SELECT
			G.MtGenerator_Id AS GeneratorId
		   ,G.MtGenerator_Name AS GeneratorName
		FROM MtContractRegistration CR
		INNER JOIN MtPartyCategory PC
			ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id
		INNER JOIN MtGenerator G
			ON G.MtPartyCategory_Id = CR.MtContractRegistration_SellerCategoryId
		WHERE MtContractRegistration_Id IN (SELECT
				MtContractRegistration_Id
			FROM #ContractData
			WHERE SrCategory_Code = 'GEN')
		AND ISNULL(MtContractRegistration_IsDeleted, 0) = 0
		AND ISNULL(G.isDeleted, 0) = 0
		AND ISNULL(MtGenerator_IsDeleted, 0) = 0
		AND ISNULL(PC.isDeleted, 0) = 0

	END
END
