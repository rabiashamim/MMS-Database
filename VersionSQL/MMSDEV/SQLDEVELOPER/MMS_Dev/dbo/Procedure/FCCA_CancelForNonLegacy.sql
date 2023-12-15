/****** Object:  Procedure [dbo].[FCCA_CancelForNonLegacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================          
-- Author: Ali Imran | Ammama Gill        
-- CREATE date: 15 Jun 2023        
-- ALTER date:         
-- Description:      
/*      
dbo.FCCA_CancelForNonLegacy 22,'0167-12-000101','0167-12-000105','0167-12-000000 to 0167-12-002500',1       
*/
-- =================================================================================         
CREATE   Procedure dbo.FCCA_CancelForNonLegacy @pFCCAMaster_Id DECIMAL(18, 0)
, @pFromCertificate VARCHAR(15)
, @pToCertificate VARCHAR(15)
, @pSelectedRange VARCHAR(50)
, @pUserId INT
AS
BEGIN

	/******************************************************************************************************************        
             Validate selected from and to certificates        
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

	/******************************************************************************************************************        
                 
             *******************************************************************************************************************/
	DECLARE @vOwnerPartyId DECIMAL(18, 0);
	SELECT
		@vOwnerPartyId = FM.MtPartyRegisteration_Id
	FROM MtFCCAMaster FM
	WHERE FM.MtFCCAMaster_Id = @pFCCAMaster_Id

	SELECT
		* INTO #CertificatesIdentified
	FROM MtFCCDetails
	WHERE MtFCCDetails_OwnerPartyId = @vOwnerPartyId
	AND MtFCCDetails_IsDeleted = 0
	AND MtFCCDetails_IsCancelled = 0
	AND MtFCCDetails_Status = 0
	AND MtFCCDetails_CertificateId BETWEEN @pFromCertificate AND @pToCertificate

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM #CertificatesIdentified)
	BEGIN

		RAISERROR ('No Certificates are identified between the range to allowed cancel.', 16, -1)
		RETURN;
	END

	UPDATE MtFCCDetails
	SET MtFCCDetails_IsCancelled = 1
		--,MtFCCDetails_ToBeCanceledFlag=0      
	   ,MtFCCDetails_ModifiedBy = @pUserId
	   ,MtFCCDetails_ModifiedOn = GETDATE()
	FROM MtFCCDetails
	WHERE MtFCCDetails_OwnerPartyId = @vOwnerPartyId
	AND MtFCCDetails_IsDeleted = 0
	AND MtFCCDetails_IsCancelled = 0
	AND MtFCCDetails_Status = 0
	AND MtFCCDetails_CertificateId BETWEEN @pFromCertificate AND @pToCertificate



	/******************************************************************************************************************        
           Update to be cancelled bits to 0      
             *******************************************************************************************************************/



	--SELECT    
	-- @vTotalCancelledCertCount = COUNT(MtFCCDetails_CertificateId)    
	--FROM MtFCCDetails    
	--WHERE MtFCCDetails_CertificateId BETWEEN @pFromCertificate AND @pToCertificate    
	--AND MtFCCDetails_IsDeleted = 0;    

	--;    
	--WITH cte_CancelledCertificates    
	--AS    
	--(SELECT    
	--  ROW_NUMBER() OVER (ORDER BY MtFCCDetails_CertificateId ASC) AS rowNumber    
	--    ,MtFCCDetails_CertificateId    
	--    ,MtGenerator_Id    
	-- FROM MtFCCDetails fccd    
	-- INNER JOIN MtFCCMaster fcc    
	--  ON fccd.MtFCCMaster_Id = fcc.MtFCCMaster_Id    
	-- WHERE MtGenerator_Id = @vGeneratorId    
	-- AND ISNULL(MtFCCDetails_ToBeCanceledFlag, 0) = 1)    

	--UPDATE fccd    
	--SET MtFCCDetails_ToBeCanceledDate = NULL    
	--   ,MtFCCDetails_ToBeCanceledFlag = 0    
	--FROM cte_CancelledCertificates CC    
	--INNER JOIN MtFCCDetails fccd    
	-- ON CC.MtFCCDetails_CertificateId = fccd.MtFCCDetails_CertificateId    
	--WHERE rowNumber BETWEEN 1 AND @vTotalCancelledCertCount    




	--/*****************************************************************************************          
	--    FCCA Generator details Backup        
	--    *****************************************************************************************/    

	DECLARE @vGeneratorId DECIMAL(18, 0);

	SELECT
		@vGeneratorId = MtGenerator_Id
	FROM MtFCCMaster fcc
	INNER JOIN MtFCCDetails fccd
		ON fcc.MtFCCMaster_Id = fccd.MtFCCMaster_Id
	WHERE MtFCCDetails_CertificateId = @pFromCertificate

	INSERT INTO MtFCCAGeneratorDetailsHistory (MtFCCAGeneratorDetails_Id,
	[MtFCCAGenerator_Id],
	MtFCCAGeneratorDetails_FromCertificate,
	MtFCCAGeneratorDetails_ToCertificate,
	MtFCCAGeneratorDetails_RangeCapacity,
	MtFCCAGeneratorDetails_RangeTotalCertificates,
	MtFCCAGeneratorDetails_IsCancelled,
	MtFCCAGeneratorDetails_CancelledDate,
	MtFCCAGeneratorDetails_CreatedBy,
	MtFCCAGeneratorDetails_CreatedOn)

		SELECT
			MtFCCAGeneratorDetails_Id
		   ,[MtFCCAGenerator_Id]
		   ,@pFromCertificate
		   ,@pToCertificate
		   ,(CAST(RIGHT(@pToCertificate, 6) AS DECIMAL(18, 2)) - CAST(RIGHT(@pFromCertificate, 6) AS DECIMAL(18, 2))) / 10
		   ,(CAST(RIGHT(@pToCertificate, 6) AS INT) - CAST(RIGHT(@pFromCertificate, 6) AS INT))
		   ,1
		   ,GETDATE()
		   ,@pUserId
		   ,GETDATE()
		FROM MtFCCAGeneratorDetails
		WHERE MtFCCAGeneratorDetails_Id IN (SELECT TOP 1
				fccagd.MtFCCAGeneratorDetails_Id
			FROM MtFCCAGenerator fccag
			INNER JOIN MtFCCAGeneratorDetails fccagd
				ON fccag.MtFCCAGenerator_Id = fccagd.MtFCCAGenerator_Id
			WHERE fccag.MtFCCAMaster_Id = @pFCCAMaster_Id
			AND fccag.MtGenerator_Id = @vGeneratorId
			AND MtFCCAGenerator_IsDeleted = 0
			AND ISNULL(MtFCCAGeneratorDetails_Isdeleted, 0) = 0
			ORDER BY fccagd.MtFCCAGeneratorDetails_Id
			DESC)


	/***************************************************************************        
           Logs section        
         ****************************************************************************/

	DECLARE @output VARCHAR(MAX);
	SET @output = 'Certificates cancelled: ' + CAST(@vGeneratorId AS VARCHAR(10)) + ' with name ' + (SELECT
			MtGenerator_Name
		FROM MtGenerator
		WHERE MtGenerator_Id = @vGeneratorId)
	+ '.';

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Certificate Administration'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output

/***************************************************************************        
    Logs section        
   ****************************************************************************/

END
