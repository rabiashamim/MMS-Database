/****** Object:  Procedure [dbo].[FCCA_ExecutionForNonLegacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Ali Imran | Ammama Gill     
-- CREATE date: 07 june 2023     
-- ALTER date:       
-- Description:       
/*  dbo.FCCA_ExecutionForNonLegacy     
 @pContractId  = 123     
,@pGeneratorId = 167    
,@pFromCertificate = '0167-12-000011'    
,@pToCertificate  = '0167-12-000020'    
,@pUserId  = 1    
*/
-- =================================================================================     

CREATE   Procedure dbo.FCCA_ExecutionForNonLegacy @pContractId DECIMAL(18, 0)
, @pGeneratorId DECIMAL(18, 0)
, @pFromCertificate VARCHAR(15)
, @pToCertificate VARCHAR(15)
, @pUserId INT
, @pSelectedRange VARCHAR(50)

AS
BEGIN




	/*****************************************************************************************    
    Non-Legacy Generator | FCC Generation State = Draft and attempting Contract Modification involving that Generator  
    *****************************************************************************************/
	DROP TABLE IF EXISTS #UnapprovedFCCs;
	DROP TABLE IF EXISTS #listofNoApproved;

	SELECT
		* INTO #UnapprovedFCCs
	FROM MtFCCMaster FCC
	WHERE FCC.MtFCCMaster_ApprovalCode <> 'Approved'
	AND MtGenerator_Id = @pGeneratorId
	AND ISNULL(MtFCCMaster_IsDeleted, 0) = 0;

	IF EXISTS (SELECT
			TOP 1
				1
			FROM #UnapprovedFCCs)
	BEGIN
		SELECT
			'Process ID ' + CAST(MtFCCMaster_Id AS VARCHAR(5))
			+ ' ( ' + CAST(MtFCCMaster_IssuanceDate AS VARCHAR(12)) + ' ) of the generator '
			+ CAST(MtGenerator_Id AS VARCHAR(5)) + ' is in process.' AS Msg INTO #listofNoApproved
		FROM #UnapprovedFCCs


		DECLARE @listStr VARCHAR(MAX)
		SELECT
			@listStr = COALESCE(@listStr + ',', '') + msg
		FROM #listofNoApproved
		SET @listStr = @listStr + ' Either Approve or Reject that Draft instance to initiate assignment of Firm Capacity Certificates as   
per the revised certificates.'

		RAISERROR (@listStr, 16, -1);
		RETURN;
	END


	/******************************************************************************************************************    
    --    Validate selected from and to certificates    
    *******************************************************************************************************************/

	DECLARE @vRangeMin VARCHAR(15)
		   ,@vRangeMax VARCHAR(15);
	SELECT
		@vRangeMin = MIN(value)
	   ,@vRangeMax = MAX(value)
	FROM STRING_SPLIT(@pSelectedRange, ' ')
	WHERE RTRIM(value) <> ''
	AND value <> 'to';

	IF @pFromCertificate NOT BETWEEN @vRangeMin AND @vRangeMax
	BEGIN
		RAISERROR ('From Certificate ID is not within the selected certificates range.', 16, -1);
		RETURN;

	END
	IF @pToCertificate NOT BETWEEN @vRangeMin AND @vRangeMax
	BEGIN
		RAISERROR ('To Certificate ID is not within the selected certificates range.', 16, -1);
		RETURN;
	END


	/*****************************************************************************************    
    Firm Capacity Certificates Expiry Date of the Sellers should be greater than Contract End date.  
    *****************************************************************************************/

	DECLARE @vContractEndDate DATETIME = NULL
		   ,@vCertificateExpiryDate DATETIME = NULL
		   ,@vLuFirmCapacityType_Id INT = 0;
	SELECT
		@vContractEndDate =
		MtContractRegistration_EffectiveTo
	FROM MtContractRegistration CR
	WHERE CR.MtContractRegistration_Id = @pContractId

	SELECT
		@vLuFirmCapacityType_Id = LuFirmCapacityType_Id
	   ,@vCertificateExpiryDate =
		CONVERT(DATE, MtFCCMaster_ExpiryDate)
	FROM MtFCCDetails FCCD
	INNER JOIN MtFCCMaster FCC
		ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
	WHERE MtFCCDetails_CertificateId = @pToCertificate


	IF (@vCertificateExpiryDate < @vContractEndDate
		AND @vLuFirmCapacityType_Id <> 1)
	BEGIN
		RAISERROR ('Expriy of certificates should be greater than contract end date.', 16, -1);
		RETURN;
	END
	/******************************************************************************************************************    
      
    *******************************************************************************************************************/



	DECLARE @vSellerPartyId DECIMAL(18, 0);
	DECLARE @vBuyerPartyId DECIMAL(18, 0);
	DECLARE @vFCCAMaster_Id DECIMAL(18, 0);
	DECLARE @vSellerCategoryCode VARCHAR(4);
	SELECT
		@vSellerPartyId = MtContractRegistration_SellerId
	   ,@vBuyerPartyId = MtContractRegistration_BuyerId
	   ,@vSellerCategoryCode = mpc.SrCategory_Code      --MtContractRegistration_SellerCategoryId  
	FROM MtContractRegistration CR
	JOIN MtPartyCategory mpc
		ON CR.MtContractRegistration_SellerCategoryId = mpc.MtPartyCategory_Id
	WHERE MtContractRegistration_Id = @pContractId


	/******************************************************************************************************************    
      
    *******************************************************************************************************************/

	IF (@vSellerCategoryCode NOT IN ('GEN', 'EGEN'))
	BEGIN
		EXECUTE Insert_ContractCertificates @pContractId
										   ,@pFromCertificate
										   ,@pToCertificate
										   ,@pGeneratorId
										   ,@pUserId

		/******************************************************************************************************************    
	    -- 5 Mark Certificate Blocked    
	    *******************************************************************************************************************/
		EXECUTE FCC_ChangeOwnerShip @vBuyerPartyId
								   ,@pFromCertificate
								   ,@pToCertificate
								   ,@pUserId

		RETURN;
	END

	/******************************************************************************************************************    
      
    *******************************************************************************************************************/

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM MtFCCAMaster
			WHERE MtPartyRegisteration_Id = @vSellerPartyId
			AND MtFCCAMaster_IsDeleted = 0)
	BEGIN
		INSERT INTO [dbo].[MtFCCAMaster] ([MtPartyRegisteration_Id]
		, [MtFCCAMaster_ApprovalStatus]
		, [MtFCCAMaster_KEShare]
		, [MtFCCAMaster_CreatedBy]
		, [MtFCCAMaster_CreatedOn]
		, [MtFCCAMaster_Status])
			VALUES (@vSellerPartyId, 'Draft', 0, @pUserId, GETDATE(), 'New')

		DECLARE @vFCDMasterId DECIMAL(18, 0) = scope_identity();

		/***************************************************************************        
	           Logs section        
	         ****************************************************************************/

		DECLARE @output VARCHAR(MAX);
		SET @output = 'New Process Created: ' + CAST(@vFCDMasterId AS VARCHAR(10)) + ' with name ' + (SELECT
				MtPartyRegisteration_Name
			FROM MtPartyRegisteration
			WHERE MtPartyRegisteration_Id = @vSellerPartyId)
		+ '.';

		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Certificate Administration'
							   ,@CrudOperationName = 'Create'
							   ,@logMessage = @output

	/***************************************************************************        
           Logs section        
          ****************************************************************************/


	END

	SELECT
		@vFCCAMaster_Id = MtFCCAMaster_Id
	FROM [dbo].[MtFCCAMaster]
	WHERE MtPartyRegisteration_Id = @vSellerPartyId
	AND MtFCCAMaster_IsDeleted = 0


	/***************************************************************************        
           Logs section        
         ****************************************************************************/

	SET @output = 'Certificate assignment started: ' + CAST(@pGeneratorId AS VARCHAR(10)) + ' with name ' + (SELECT
			MtGenerator_Name
		FROM MtGenerator
		WHERE MtGenerator_Id = @pGeneratorId)
	+ '.';

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Certificate Administration'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output

	/***************************************************************************        
           Logs section        
          ****************************************************************************/


	/******************************************************************************************************************    
    -- 2 [MtFCCAGenerator]    
    *******************************************************************************************************************/
	DECLARE @vFCCMaster_Id DECIMAL(18, 0);
	DECLARE @vIFC DECIMAL(25, 13);

	----todo: Valid IFC is maintained in table FCDGenerators. Please Review - Ammama  

	SELECT TOP 1
		@vFCCMaster_Id = MtFCCMaster_Id
	   ,@vIFC = MtFCDGenerators_InitialFirmCapacity
	FROM MtFCCMaster M
	JOIN MtFCDGenerators FG
		ON M.MtFCDMaster_Id = FG.MtFCDMaster_Id
	WHERE M.MtGenerator_Id = @pGeneratorId
	AND MtFCCMaster_IsDeleted = 0
	AND MtFCCMaster_ApprovalCode = 'Approved'
	ORDER BY MtFCCMaster_Id DESC


	IF NOT EXISTS (SELECT TOP 1
				1
			FROM MtFCCAGenerator
			WHERE MtFCCAGenerator_IsDeleted = 0
			AND MtFCCAMaster_Id = @vFCCAMaster_Id
			AND MtGenerator_Id = @pGeneratorId)
	BEGIN
		INSERT INTO [dbo].[MtFCCAGenerator] ([MtFCCAMaster_Id]
		, [MtFCCMaster_Id]
		, [MtGenerator_Id]
		, [MtFCCAGenerator_IFC]
		, [MtFCCAGenerator_KEShare]
		, [MtFCCAGenerator_WithoutKE]
		, [MtFCCAGenerator_CreatedBy]
		, [MtFCCAGenerator_CreatedOn])
			VALUES (@vFCCAMaster_Id, @vFCCMaster_Id, @pGeneratorId, @vIFC, 0 --not required for non legacy    
			, 0 -- not required for non legacy    
			, @pUserId, GETDATE())

	END

	--- Against every FCCAMaster_Id there can be multiple generators. Which generator are we picking here? - use generator Id passed as input. Ammama  
	DECLARE @vMtFCCAGenerator_Id DECIMAL(18, 0);
	SELECT
		@vMtFCCAGenerator_Id = MtFCCAGenerator_Id
	FROM MtFCCAGenerator
	WHERE MtFCCAGenerator_IsDeleted = 0
	AND MtFCCAMaster_Id = @vFCCAMaster_Id
	AND MtGenerator_Id = @pGeneratorId

	/******************************************************************************************************************    
    -- 3  MtFCCADetails    
    *******************************************************************************************************************/
	IF NOT EXISTS (SELECT
			TOP 1
				1
			FROM MtFCCADetails
			WHERE MtContractRegistration_Id = @pContractId
			AND MtPartyRegistration_BuyerId = @vBuyerPartyId
			AND MtFCCADetails_IsDeleted = 0)
	BEGIN

		--- Allocation factors are not needed for Non Legacy Generators.Please review - Ammama  
		DECLARE @vAllocationFactore DECIMAL(18, 2)
		SELECT
			@vAllocationFactore = LAF.LuAllocationFactors_Factor
		FROM MtContractRegistration CR
		INNER JOIN MtPartyRegisteration PR
			ON CR.MtContractRegistration_BuyerId = PR.MtPartyRegisteration_Id
		INNER JOIN LuAllocationFactors LAF
			ON PR.MtPartyRegisteration_Id = LAF.MtPartyRegisteration_Id
		WHERE CR.MtContractRegistration_Id = @pContractId
		AND CR.MtContractRegistration_IsDeleted = 0
		AND PR.isDeleted = 0



		INSERT INTO MtFCCADetails (MtPartyRegistration_BuyerId
		, MtContractRegistration_Id
		, MtFCCAGenerator_Id
		, MtFCCADetails_AllocationFactor
		, MtFCCADetails_CreatedBy
		, MtFCCADetails_CreatedOn)
			VALUES (@vBuyerPartyId, @pContractId, @vMtFCCAGenerator_Id, @vAllocationFactore, @pUserId, GETDATE())

	END


	DECLARE @vMtFCCADetails_Id DECIMAL(18, 0);
	SELECT
		@vMtFCCADetails_Id = MtFCCADetails_Id
	FROM MtFCCADetails
	WHERE MtContractRegistration_Id = @pContractId
	AND MtPartyRegistration_BuyerId = @vBuyerPartyId
	AND MtFCCAGenerator_Id = @vMtFCCAGenerator_Id
	AND MtFCCADetails_IsDeleted = 0
	/******************************************************************************************************************    
    -- 4   MtFCCAAssigmentDetails    
    *******************************************************************************************************************/
	/*IF @vSellerCategoryCode IN ('EGEN', 'GEN')  
    BEGIN  
     IF NOT EXISTS (SELECT TOP 1  
        1  
       FROM [dbo].[MtFCCAAssigmentDetails]  
       WHERE MtFCCADetails_Id = @vMtFCCADetails_Id  
       AND MtFCCAAssigmentDetails_FromCertificate = @pFromCertificate  
       AND MtFCCAAssigmentDetails_ToCertificate = @pToCertificate  
      --and MtFCCAAssigmentDetails_OwnerPartyId <> @vBuyerPartyId  
      ) -- check & avoid if same range with same owner is being added.   
     BEGIN  
     
     
     
      INSERT INTO [dbo].[MtFCCAAssigmentDetails] (MtFCCADetails_Id  
      , MtFCCAAssigmentDetails_FromCertificate  
      , MtFCCAAssigmentDetails_ToCertificate  
      , MtFCCAAssigmentDetails_OwnerPartyId  
      , MtFCCAAssigmentDetails_CreatedBy)  
       VALUES (@vMtFCCADetails_Id, @pFromCertificate, @pToCertificate, @vBuyerPartyId, @pUserId)  
     
     END  
     
    END  
    */

	/*******************************************************************************************************************    
      
    *******************************************************************************************************************/
	--EXECUTE ADD_MtFCCAAssigmentDetails @vMtFCCADetails_Id  
	--          ,@pFromCertificate  
	--          ,@pToCertificate  
	--          ,@vBuyerPartyId  
	--          ,@pUserId  

	EXECUTE Insert_ContractCertificates @pContractId
									   ,@pFromCertificate
									   ,@pToCertificate
									   ,@pGeneratorId
									   ,@pUserId

	/******************************************************************************************************************    
    -- 5 Mark Certificate Blocked    
    *******************************************************************************************************************/


	EXECUTE FCC_ChangeOwnerShip @vBuyerPartyId
							   ,@pFromCertificate
							   ,@pToCertificate
							   ,@pUserId

	/******************************************************************************************************************    
    --  MtFCCAGeneratorDetails => this table is not used in non-legacy but only used in legacy    
    *******************************************************************************************************************/

	INSERT INTO MtFCCAGeneratorDetails ([MtFCCAGenerator_Id],
	MtFCCAGeneratorDetails_FromCertificate,
	MtFCCAGeneratorDetails_ToCertificate,
	MtFCCAGeneratorDetails_RangeCapacity,
	MtFCCAGeneratorDetails_RangeTotalCertificates,
	MtFCCAGeneratorDetails_IsCancelled,
	MtFCCAGeneratorDetails_CancelledDate,
	MtFCCAGeneratorDetails_CreatedBy)

		SELECT TOP 1
			g.MtFCCAGenerator_Id
		   ,@pFromCertificate
		   ,@pToCertificate
		   ,0
		   ,0
		   ,0
		   ,GETDATE()
		   ,@pUserId
		FROM MtFCCAGenerator g

		WHERE g.MtFCCAMaster_Id = @vFCCAMaster_Id
		AND g.MtGenerator_Id = @pGeneratorId
		AND g.MtFCCAGenerator_IsDeleted = 0

	/******************************************************************************************************************    
    --     
    *******************************************************************************************************************/
	UPDATE FCCA
	SET MtFCCAMaster_ModifiedOn = GETDATE()
	   ,MtFCCAMaster_ModifiedBy = @pUserId
	   ,MtFCCAMaster_Status = 'Executed'
	FROM MtFCCAMaster FCCA
	WHERE FCCA.MtFCCAMaster_Id = @vFCCAMaster_Id

	/***************************************************************************        
       Logs section        
     ****************************************************************************/

	SET @output = 'Certificate assignment completed: ' + CAST(@pGeneratorId AS VARCHAR(10)) + ' with name ' + (SELECT
			MtGenerator_Name
		FROM MtGenerator
		WHERE MtGenerator_Id = @pGeneratorId)
	+ '.';

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Certificate Administration'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output

/***************************************************************************        
    Logs section        
   ****************************************************************************/
END
