/****** Object:  Procedure [dbo].[ContractReg_InsertUpdateContractTradingCdps_bk]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ammama
-- CREATE date: Nov 15, 2022 
-- ALTER date: 
-- Reviewer:
-- Description: 
-- =============================================    
Create PROCEDURE dbo.ContractReg_InsertUpdateContractTradingCdps_bk @pMtContractRegistration_Id DECIMAL(18, 0),
@pRuCDPDetail_Id VARCHAR(256),
@puser_id DECIMAL(18, 0) = NULL
AS
	IF EXISTS (SELECT TOP 1
				1
			FROM MtContractRegistration
			WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
			AND MtContractRegistration_Status = 'CDRT')
	BEGIN
		DELETE FROM MtContractTradingCDPs
		WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
	END

	CREATE TABLE #temp (
		value VARCHAR(256)
	   ,RuCDPDetail_Id DECIMAL(18, 0)
	)

	IF ISNULL(@pRuCDPDetail_Id, '') != ''
	BEGIN
		INSERT INTO #temp (value)
			SELECT
				value
			FROM STRING_SPLIT(@pRuCDPDetail_Id, ',')

		--ALTER TABLE #temp ADD RuCDPDetail_Id DECIMAL(18, 0)  
		UPDATE t
		SET RuCDPDetail_Id = c.RuCDPDetail_Id
		FROM #temp t
		INNER JOIN RuCDPDetail c
			ON t.value = c.RuCDPDetail_CdpId

	END
	--;with cte as(    
	SELECT DISTINCT
		RuCDPDetail_Id INTO #existing_CDPs
	FROM MtContractTradingCDPs
	WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
	AND MtContractTradingCDPs_IsDeleted = 0
	--),  


	;
	WITH cte_remove_CPDs
	AS
	(SELECT
			*
		FROM #existing_CDPs
		WHERE RuCDPDetail_Id NOT IN (SELECT
				RuCDPDetail_Id
			FROM #temp))
	UPDATE MtContractTradingCDPs
	SET MtContractTradingCDPs_IsDeleted = 1
	WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
	AND RuCDPDetail_Id IN (SELECT
			RuCDPDetail_Id
		FROM cte_remove_CPDs);
	WITH cte
	AS
	(SELECT DISTINCT
			t.RuCDPDetail_Id
		FROM #temp t
		LEFT JOIN #existing_CDPs e
			ON t.RuCDPDetail_Id = e.RuCDPDetail_Id
		WHERE e.RuCDPDetail_Id IS NULL)
	INSERT INTO MtContractTradingCDPs (MtContractRegistration_Id,
	RuCDPDetail_Id,
	MtContractTradingCDPs_CreatedBy,
	MtContractTradingCDPs_CreatedOn,
	MtContractTradingCDPs_ModifiedBy,
	MtContractTradingCDPs_ModifiedOn,
	MtContractTradingCDPs_IsDeleted)
		SELECT
			@pMtContractRegistration_Id
		   ,RuCDPDetail_Id
		   ,@puser_id
		   ,GETDATE()
		   ,NULL
		   ,NULL
		   ,0
		FROM cte
