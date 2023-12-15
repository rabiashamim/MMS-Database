/****** Object:  Procedure [dbo].[ContractReg_InsertUpdateContractTradingCdps]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================  
-- Author:  Ammama Gill
-- CREATE OR ALTER date: Nov 15, 2022 
-- ALTER date: 
-- Reviewer:
-- Description: 
-- =============================================    
CREATE   PROCEDURE dbo.ContractReg_InsertUpdateContractTradingCdps 
@pMtContractRegistration_Id DECIMAL(18, 0),
@pRuCDPDetail_Id VARCHAR(max),
@pSelectFromAllCDPs bit=0,
@puser_id DECIMAL(18, 0) = NULL
AS
BEGIN
--------------------------------------------------------------------------------------
/*
	IF EXISTS (SELECT TOP 1
				1
			FROM MtContractRegistration
			WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
			AND MtContractRegistration_Status = 'CDRT')
	BEGIN
		DELETE FROM MtContractTradingCDPs
		WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
	END
*/
--------------------------------------------------------------------------------------

	SELECT
		RuCDPDetail_Id
	   ,RuCDPDetail_CdpId INTO #selectedCdps
	FROM RuCDPDetail
	WHERE RuCDPDetail_CdpId IN (SELECT
			value
		FROM STRING_SPLIT(@pRuCDPDetail_Id, ','));

	--------------------------------------------------------------------------------------
	-- check if entry in physical assets than return not perform futher action. first reset from
	-- physical assets than come back and cdp remove than.(commented by Ali Imran) 
	--------------------------------------------------------------------------------------

		WITH  cte_checkunit AS (
	SELECT MtGenerationUnit_Id AS GenUnitId , RuCDPDetail_CdpId AS Cdp_Id, MtGenerationUnit_UnitName AS UnitName FROM vw_CdpGenerators 
	WHERE RuCDPDetail_Id IN(
	SELECT RuCDPDetail_Id FROM MtContractTradingCDPs
	WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
	AND MtContractTradingCDPs_IsDeleted = 0
	AND RuCDPDetail_Id NOT IN (SELECT
			RuCDPDetail_Id
		FROM #selectedCdps))
	)
	
	SELECT *  INTO #ExistsInPhysicalAssets FROM cte_checkunit WHERE GenUnitId IN  (
	SELECT MtGenerationUnit_Id FROM MtContractPhysicalAssets WHERE MtContractRegistration_Id=@pMtContractRegistration_Id
	AND MtContractPhysicalAssets_IsDeleted=0
	)
	IF EXISTS (SELECT 1 FROM #ExistsInPhysicalAssets)
	BEGIN
		BEGIN
		RAISERROR('Please reset first from physical assets than un-checked the cdp', 16, -1)
		RETURN;
	END
	END

	--------------------------------------------------------------------------------------
	-- remove cdps from Trading points
	--------------------------------------------------------------------------------------
	if(@pSelectFromAllCDPs=0)
	BEGIN
	UPDATE MtContractTradingCDPs
	SET MtContractTradingCDPs_IsDeleted = 1
	,MtContractTradingCDPs_ModifiedOn=GETDATE()
	,MtContractTradingCDPs_ModifiedBy=@puser_id
	WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
	AND MtContractTradingCDPs_IsDeleted = 0
	AND RuCDPDetail_Id NOT IN (SELECT
			RuCDPDetail_Id
		FROM #selectedCdps)
	END
---------------logs------------					
			declare @output VARCHAR(max);
			SET @output='CDPs Trading Points Updated. Contract ID:' + convert(varchar(max),@pMtContractRegistration_Id)

				EXEC [dbo].[SystemLogs]   
				 @moduleName='Contract Registration',  
				 @CrudOperationName='Update',  
				 @logMessage=@output,
				 @user=@puser_id
	--------------------------------------------------------------------------------------
	-- insert new cpds in Trading points
	--------------------------------------------------------------------------------------
	IF NOT ExISTS(
	SELECT top 1 1 FROM MtContractTradingCDPs WHERE MtContractTradingCDPs_IsDeleted=0 and MtContractRegistration_Id=@pMtContractRegistration_Id
	and RuCDPDetail_Id in (Select RuCDPDetail_Id FROM #selectedCdps)
	)
	BEGIN
	INSERT INTO MtContractTradingCDPs (MtContractRegistration_Id,
	RuCDPDetail_Id,
	MtContractTradingCDPs_CreatedBy,
	MtContractTradingCDPs_CreatedOn,
		MtContractTradingCDPs_IsDeleted)
		SELECT
			@pMtContractRegistration_Id
		   ,RuCDPDetail_Id
		   ,@puser_id
		   ,GETDATE()
		   ,0
		FROM #selectedCdps t
		WHERE RuCDPDetail_Id NOT IN (SELECT
				RuCDPDetail_Id
			FROM MtContractTradingCDPs
			WHERE MtContractRegistration_Id = @pMtContractRegistration_Id
			AND MtContractTradingCDPs_IsDeleted = 0)
END
--------------------------------------------------------------------------------------

END
