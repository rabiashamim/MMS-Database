/****** Object:  Procedure [dbo].[FCCA_Execution]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ================================================================================      
-- Author:  Ammama Gill    
-- CREATE date: 04 May 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
--[FCCA_Execution] 17,1  
CREATE   Procedure dbo.FCCA_Execution (@pFCCAMasterId DECIMAL(18, 0), @pUserId INT)
AS
BEGIN

	BEGIN TRY

		/*****************************************************************************************    
	  If any "Firm Capacity Certificate Generation" process regarding legacy generator is in the not approved state or waiting  
	  for approval, then Firm Capacity Administration Assignment can not be initiated. A message will come that   
	  "Firm Capacity Certificate Generation" process ID ___ dated ____ of the Generator XXX is in process,  
	  either Approve or Reject that Draft instance to initiate assignment of Firm Capacity Certificates as   
	  per the revised certificates. Stop that process here.  
	      *****************************************************************************************/
		SELECT
			* INTO #CheckFCCProcess
		FROM MtFCCMaster
		WHERE MtFCCMaster_ApprovalCode <> 'Approved'
		AND MtFCCMaster_IsDeleted = 0

		IF EXISTS (SELECT TOP 1
					1
				FROM #CheckFCCProcess)
		BEGIN
			SELECT
				'Process ID ' + CAST(MtFCCMaster_Id AS VARCHAR(5))
				+ ' ( ' + CAST(MtFCCMaster_IssuanceDate AS VARCHAR(12)) + ' ) of the generator'
				+ CAST(MtGenerator_Id AS VARCHAR(5)) + ' is in process.' AS Msg INTO #listofNoApproved
			FROM #CheckFCCProcess


			DECLARE @listStr VARCHAR(MAX)
			SELECT
				@listStr = COALESCE(@listStr + ',', '') + msg
			FROM #listofNoApproved
			SET @listStr = @listStr + ' Either Approve or Reject that Draft instance to initiate assignment of Firm Capacity Certificates as   
per the revised certificates.'

			RAISERROR (@listStr, 16, -1);

			UPDATE FCCA
			SET MtFCCAMaster_ModifiedOn = GETDATE()
			   ,MtFCCAMaster_ModifiedBy = @pUserId
			   ,MtFCCAMaster_Status = 'Interrupted'
			FROM MtFCCAMaster FCCA
			WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

			/***************************************************************************    
		    Logs section    
		  ****************************************************************************/

			DECLARE @output VARCHAR(MAX);
			SET @output = 'Process Execution Interrupted: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
					ISNULL(MtPartyRegisteration_Name, '')
				FROM MtFCCAMaster fcca
				INNER JOIN MtPartyRegisteration pr
					ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
				WHERE MtFCCAMaster_Id = @pFCCAMasterId);

			EXEC [dbo].[SystemLogs] @user = @pUserId
								   ,@moduleName = 'Firm Capacity Certificate Administration'
								   ,@CrudOperationName = 'Update'
								   ,@logMessage = @output

			/***************************************************************************    
		     Logs section    
		    ****************************************************************************/

			RETURN;

		END
		/*****************************************************************************************    
	       Check if any FCC exists against the said party  
	       *****************************************************************************************/
		DECLARE @vFCCGeneratorsCount INT = 0
			   ,@vPartyName VARCHAR(MAX) = '';
		SELECT
			@vFCCGeneratorsCount = COUNT(DISTINCT
			GP.MtGenerator_Id)
		FROM vw_GeneratorParties GP
		INNER JOIN MtFCCMaster FCC
			ON GP.MtGenerator_Id = FCC.MtGenerator_Id
		WHERE GP.MtPartyRegisteration_Id = (SELECT
				FCCA.MtPartyRegisteration_Id
			FROM MtFCCAMaster FCCA
			WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)
		AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0
		AND FCC.MtFCCMaster_ApprovalCode = 'Approved'

		IF @vFCCGeneratorsCount = 0
		BEGIN
			SELECT
				@vPartyName = GP.MtPartyRegisteration_Name
			FROM vw_GeneratorParties GP
			WHERE GP.MtPartyRegisteration_Id = (SELECT
					FCCA.MtPartyRegisteration_Id
				FROM MtFCCAMaster FCCA
				WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)

			RAISERROR ('No FCC exists against the generators of party %s', 16, -1, @vPartyName);

			RETURN;
		END


		/*****************************************************************************************    
	       Get KE Share   
	       *****************************************************************************************/
		DECLARE @KEShare DECIMAL(25, 13);

		IF EXISTS (SELECT TOP 1
					1
				FROM MtFCCAMaster mf
				WHERE mf.MtFCCAMaster_Id = @pFCCAMasterId)
		BEGIN


			SELECT TOP 1
				@KEShare = rrv.RuReferenceValue_Value
			FROM SrReferenceType srt
			INNER JOIN RuReferenceValue rrv
				ON srt.SrReferenceType_Id = rrv.SrReferenceType_Id
			WHERE srt.SrReferenceType_Name = 'KE Share'
			AND ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
			AND ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0
			ORDER BY rrv.RuReferenceValue_EffectiveTo DESC;

			IF @KEShare = NULL
			BEGIN
				RAISERROR ('KE Share value is missing. FCCA cannot be executed.', 16, -1);
				RETURN;
			END


			UPDATE FCCA
			SET MtFCCAMaster_KEShare = @KEShare
			   ,MtFCCAMaster_ModifiedOn = GETDATE()
			   ,MtFCCAMaster_ModifiedBy = @pUserId
			   ,MtFCCAMaster_Status = 'Inprocess'
			FROM MtFCCAMaster FCCA
			WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

			/***************************************************************************    
		 Logs section    
		 ****************************************************************************/

			SET @output = 'Process Execution Started: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
					ISNULL(MtPartyRegisteration_Name, '')
				FROM MtFCCAMaster fcca
				INNER JOIN MtPartyRegisteration pr
					ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
				WHERE MtFCCAMaster_Id = @pFCCAMasterId);

			EXEC [dbo].[SystemLogs] @user = @pUserId
								   ,@moduleName = 'Firm Capacity Certificate Administration'
								   ,@CrudOperationName = 'Update'
								   ,@logMessage = @output

		/***************************************************************************    
	     Logs section    
	    ****************************************************************************/
		END


		/*****************************************************************************************    
	    Insert INTO FCCAGenerators    
	    *****************************************************************************************/
		IF NOT EXISTS (SELECT TOP 1
					1
				FROM MtFCCAGenerator mf
				WHERE mf.MtFCCAMaster_Id = @pFCCAMasterId)
		BEGIN
			;
			WITH cte_LatestFCC
			AS
			(SELECT
					ROW_NUMBER() OVER (PARTITION BY FCC.MtGenerator_Id ORDER BY FCC.MtFCCMaster_Id DESC) AS row_number
				   ,FCC.MtGenerator_Id
				   ,FCC.MtFCCMaster_Id
				   ,FCDG.MtFCDGenerators_InitialFirmCapacity
				FROM MtFCCMaster FCC
				INNER JOIN MtFCDGenerators FCDG
					ON FCC.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
					AND FCC.MtGenerator_Id = FCDG.MtGenerator_Id
				INNER JOIN vw_GeneratorParties GP
					ON GP.MtGenerator_Id = FCC.MtGenerator_Id
					AND GP.MtPartyRegisteration_Id = FCC.MtPartyRegistration_Id
				WHERE FCC.MtFCCMaster_TotalCertificates IS NOT NULL
				AND FCDG.MtFCDGenerators_InitialFirmCapacity IS NOT NULL
				AND FCC.MtFCCMaster_IsDeleted = 0
				AND FCDG.MtFCDGenerators_IsDeleted = 0
				AND FCC.MtFCCMaster_ApprovalCode = 'Approved'
				AND FCC.MtPartyRegistration_Id = (SELECT
						FCCA.MtPartyRegisteration_Id
					FROM MtFCCAMaster FCCA
					WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId))


			INSERT INTO MtFCCAGenerator (MtFCCAMaster_Id, MtFCCMaster_Id, MtGenerator_Id, MtFCCAGenerator_IFC, MtFCCAGenerator_CreatedBy, MtFCCAGenerator_CreatedOn)
				SELECT
					@pFCCAMasterId
				   ,MtFCCMaster_Id
				   ,MtGenerator_Id
				   ,MtFCDGenerators_InitialFirmCapacity
				   ,@pUserId
				   ,GETDATE()
				FROM cte_LatestFCC
				WHERE row_number = 1


			/*****************************************************************************************    
		  Update FCCA Generators - calculate KE Share and the leftover Capacity for DISCOs  
		  *****************************************************************************************/
			DECLARE @TotalCapacity DECIMAL(25, 13);
			SELECT
				@TotalCapacity = SUM(FCCAG.MtFCCAGenerator_IFC)
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			AND ISNULL(MtFCCAGenerator_IsDeleted, 0) = 0;

			IF @TotalCapacity < @KEShare
			BEGIN
				--- Rollback existing process.  
				EXEC FCCA_Rollback @pFCCAMasterId
								  ,@pUserId

				--- Update execution status to 'Interrupted'  
				UPDATE FCCA
				SET MtFCCAMaster_ModifiedOn = GETDATE()
				   ,MtFCCAMaster_ModifiedBy = @pUserId
				   ,MtFCCAMaster_Status = 'Interrupted'
				FROM MtFCCAMaster FCCA
				WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

				--- Raise error.  

				RAISERROR ('Total Capacity of system cannot be less than KE Share.', 16, -1);

				/***************************************************************************    
			   Logs section    
			 ****************************************************************************/

				SET @output = 'Process Execution Interrupted: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
						ISNULL(MtPartyRegisteration_Name, '')
					FROM MtFCCAMaster fcca
					INNER JOIN MtPartyRegisteration pr
						ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
					WHERE MtFCCAMaster_Id = @pFCCAMasterId);

				EXEC [dbo].[SystemLogs] @user = @pUserId
									   ,@moduleName = 'Firm Capacity Certificate Administration'
									   ,@CrudOperationName = 'Update'
									   ,@logMessage = @output

				/***************************************************************************    
			     Logs section    
			    ****************************************************************************/

				RETURN;

			END

			UPDATE FCCAG
			SET MtFCCAGenerator_KEShare = (FCCAG.MtFCCAGenerator_IFC / @TotalCapacity) * @KEShare
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId;

			UPDATE FCCAG
			SET FCCAG.MtFCCAGenerator_WithoutKE = FCCAG.MtFCCAGenerator_IFC - FCCAG.MtFCCAGenerator_KEShare
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId


			IF NOT EXISTS (SELECT
					TOP 1
						1
					FROM MtContractRegistration CR
					WHERE CR.MtContractRegistration_SellerId = (SELECT
							FCCA.MtPartyRegisteration_Id
						FROM MtFCCAMaster FCCA
						WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)
					AND CR.MtContractRegistration_Status = 'CATV'
					AND ISNULL(CR.MtContractRegistration_IsDeleted, 0) = 0)
			BEGIN

				--- Rollback existing process.  

				EXEC FCCA_Rollback @pFCCAMasterId
								  ,@pUserId;
				--- Update execution status to 'Interrupted'  
				UPDATE FCCA
				SET MtFCCAMaster_ModifiedOn = GETDATE()
				   ,MtFCCAMaster_ModifiedBy = @pUserId
				   ,MtFCCAMaster_Status = 'Interrupted'
				FROM MtFCCAMaster FCCA
				WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

				--- Raise error.  

				RAISERROR ('No active contracts for this MP exist.', 16, -1);


				/***************************************************************************    
			 Logs section    
			 ****************************************************************************/

				SET @output = 'Process Execution Interrupted: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
						ISNULL(MtPartyRegisteration_Name, '')
					FROM MtFCCAMaster fcca
					INNER JOIN MtPartyRegisteration pr
						ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
					WHERE MtFCCAMaster_Id = @pFCCAMasterId);

				EXEC [dbo].[SystemLogs] @user = @pUserId
									   ,@moduleName = 'Firm Capacity Certificate Administration'
									   ,@CrudOperationName = 'Update'
									   ,@logMessage = @output

				/***************************************************************************    
			     Logs section    
			    ****************************************************************************/

				RETURN;

			END

			/*****************************************************************************************    
		    Insert INTO FCCADetails    
		    *****************************************************************************************/


			INSERT INTO MtFCCADetails (MtPartyRegistration_BuyerId, MtContractRegistration_Id, MtFCCAGenerator_Id, MtFCCADetails_AllocationFactor, MtFCCADetails_CreatedBy, MtFCCADetails_CreatedOn)
				SELECT
					CR.MtContractRegistration_BuyerId
				   ,CR.MtContractRegistration_Id
				   ,FCCAG.MtFCCAGenerator_Id
				   ,LAF.LuAllocationFactors_Factor
				   ,@pUserId
				   ,GETDATE()
				FROM MtContractRegistration CR
				INNER JOIN MtPartyRegisteration PR
					ON CR.MtContractRegistration_BuyerId = PR.MtPartyRegisteration_Id
				INNER JOIN LuAllocationFactors LAF
					ON PR.MtPartyRegisteration_Id = LAF.MtPartyRegisteration_Id
				INNER JOIN vw_GeneratorParties GP
					ON GP.MtPartyRegisteration_Id = CR.MtContractRegistration_SellerId
				INNER JOIN MtFCCAGenerator FCCAG
					ON GP.MtGenerator_Id = FCCAG.MtGenerator_Id
				WHERE CR.MtContractRegistration_SellerId = (SELECT
						FCCA.MtPartyRegisteration_Id
					FROM MtFCCAMaster FCCA
					WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)
				AND ISNULL(PR.isDeleted, 0) = 0
				AND ISNULL(CR.MtContractRegistration_IsDeleted, 0) = 0
				AND FCCAG.MtFCCAGenerator_IsDeleted = 0
				AND CR.MtContractRegistration_Status = 'CATV';


			/*****************************************************************************************    
		    Prorate associated capacity to calculate individual disco capacity share / generator    
		    *****************************************************************************************/


			DECLARE @vKEMPId INT;
			SET @vKEMPId = 12;

			UPDATE FCCAD
			SET MtFCCADetails_AssociatedCapacity =
			CASE
				WHEN FCCAD.MtPartyRegistration_BuyerId <> @vKEMPId THEN FCCAG.MtFCCAGenerator_WithoutKE * (FCCAD.MtFCCADetails_AllocationFactor / 100)
				ELSE FCCAG.MtFCCAGenerator_KEShare
			END
			FROM MtFCCADetails FCCAD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCAG.MtFCCAGenerator_Id = FCCAD.MtFCCAGenerator_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			AND FCCAG.MtFCCAGenerator_IsDeleted = 0
			AND FCCAD.MtFCCADetails_IsDeleted = 0

			/*****************************************************************************************    
		   Update iscancelled bit to 1 for all to be cancelled certificates.  
		   *****************************************************************************************/

			UPDATE FCCD
			SET FCCD.MtFCCDetails_IsCancelled = 1
			   ,FCCD.MtFCCDetails_ToBeCanceledFlag = 0
			FROM MtFCCDetails FCCD
			INNER JOIN MtFCCMaster FCC
				ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			WHERE ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0
			AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
			AND FCCD.MtFCCDetails_ToBeCanceledFlag = 1
			AND FCCAG.MtFCCAMaster_Id = @pFCCAMasterId

			/***************************************************************************    
	  Logs section    
	  ****************************************************************************/

			SET @output = 'Certificates Cancelled: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
					ISNULL(MtPartyRegisteration_Name, '')
				FROM MtFCCAMaster fcca
				INNER JOIN MtPartyRegisteration pr
					ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
				WHERE MtFCCAMaster_Id = @pFCCAMasterId);

			EXEC [dbo].[SystemLogs] @user = @pUserId
								   ,@moduleName = 'Firm Capacity Certificate Administration'
								   ,@CrudOperationName = 'Update'
								   ,@logMessage = @output

			/***************************************************************************    
		     Logs section    
		    ****************************************************************************/


			/*****************************************************************************************    
		    Get available ranges first  
		    *****************************************************************************************/
			DROP TABLE IF EXISTS #GenCertificates;
			DROP TABLE IF EXISTS #AvailableRanges;


			SELECT
				ROW_NUMBER() OVER (PARTITION BY t.MtGenerator_Id, t.MtFCCDetails_IsCancelled, t.RowNum_WOC - t.RowNum_WC ORDER BY t.MtFCCDetails_CertificateId) AS partition_Rows
			   ,DENSE_RANK() OVER (PARTITION BY t.MtGenerator_Id ORDER BY t.MtFCCDetails_IsCancelled, t.RowNum_WOC - t.RowNum_WC) AS partition_seqnum
			   ,* INTO #GenCertificates
			FROM (SELECT
					ROW_NUMBER() OVER (PARTITION BY FCC.MtGenerator_Id, FCCD.MtFCCDetails_IsCancelled ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WC
				   ,ROW_NUMBER() OVER (PARTITION BY FCC.MtGenerator_Id ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WOC
				   ,FCC.MtGenerator_Id
				   ,FCCD.MtFCCDetails_CertificateId
				   ,FCCD.MtFCCDetails_IsCancelled
				   ,FCCAG.MtFCCAGenerator_Id

				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCC
					ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id
				INNER JOIN MtFCCAGenerator FCCAG
					ON FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
				WHERE ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0
				AND ISNULL(FCCAG.MtFCCAGenerator_IsDeleted, 0) = 0
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND FCCAG.MtFCCAMaster_Id = @pFCCAMasterId) t


			SELECT
				partition_seqnum
			   ,MtGenerator_Id
			   ,MIN(MtFCCDetails_CertificateId) AS minCert
			   ,MAX(MtFCCDetails_CertificateId) AS maxCert
			   ,MIN(RowNum_WC) AS MinRowNum
			   ,MAX(RowNum_WC) AS MaxRowNum INTO #AvailableRanges
			FROM #GenCertificates
			WHERE ISNULL(MtFCCDetails_IsCancelled, 0) = 0
			GROUP BY MtGenerator_Id
					,partition_seqnum;


			/*****************************************************************************************    
		    Get certificate count for KE per generator  
		    *****************************************************************************************/
			DROP TABLE IF EXISTS #KEShare;

			SELECT
				FCCAG.MtGenerator_Id
			   ,1 AS MinKERow
			   ,ROUND(FCCAG.MtFCCAGenerator_KEShare, 1) * 10 AS MaxKEShareRow INTO #KEShare
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId


			DROP TABLE IF EXISTS #tempCertificateDetails;

			CREATE TABLE #tempCertificateDetails (
				MtGeneratorId DECIMAL(18, 0)
			   ,IsKE BIT
			   ,MinCertificate VARCHAR(MAX)
			   ,MaxCertificate VARCHAR(MAX)
			   ,MinRowNumber INT
			   ,MaxRownumber INT
			)



			;
			WITH cte_KERanges
			AS
			(SELECT
					AR.MtGenerator_Id
				   ,AR.MinRowNum AS minRange
				   ,KES.MaxKEShareRow
				   ,CASE
						WHEN KES.MaxKEShareRow BETWEEN AR.MinRowNum AND AR.MaxRowNum THEN KES.MaxKEShareRow
						ELSE AR.MaxRowNum
					END AS maxRange
				FROM #AvailableRanges AR
				INNER JOIN #KEShare KES
					ON AR.MtGenerator_Id = KES.MtGenerator_Id)




			INSERT INTO #tempCertificateDetails
				SELECT
					MtGenerator_Id
				   ,1
				   ,(SELECT
							GC.MtFCCDetails_CertificateId
						FROM #GenCertificates GC
						WHERE GC.RowNum_WC = minRange
						AND ISNULL(GC.MtFCCDetails_IsCancelled, 0) = 0
						AND MtGenerator_Id = ker.MtGenerator_Id)
					AS MinCertificate
				   ,(SELECT
							GC.MtFCCDetails_CertificateId
						FROM #GenCertificates GC
						WHERE GC.RowNum_WC = maxRange
						AND ISNULL(GC.MtFCCDetails_IsCancelled, 0) = 0
						AND MtGenerator_Id = ker.MtGenerator_Id)
					AS MaxCertificate
				   ,minRange AS MinRowNumber
				   ,maxRange AS MaxRowNumber
				FROM cte_KERanges ker
				WHERE maxRange <= MaxKEShareRow


			/*****************************************************************************************    
		    Get the remaining Certificates and assign range to the rest of the Buyer MPs  
		    *****************************************************************************************/



			;
			WITH cte_GeneralRanges
			AS
			(SELECT
					k.MtGenerator_Id
				   ,CASE
						WHEN k.MaxKEShareRow BETWEEN AR.MinRowNum AND AR.MaxRowNum THEN k.MaxKEShareRow + 1
						ELSE AR.MinRowNum
					END
					AS minGeneralRange
				   ,CASE
						WHEN AR.MaxRowNum > k.MaxKEShareRow THEN AR.MaxRowNum --review  
					END AS maxGeneralRange



				FROM #KEShare k
				INNER JOIN #AvailableRanges AR
					ON k.MtGenerator_Id = AR.MtGenerator_Id)

			INSERT INTO #tempCertificateDetails
				SELECT
					GR.MtGenerator_Id
				   ,0
				   ,(SELECT
							GC.MtFCCDetails_CertificateId
						FROM #GenCertificates GC
						WHERE GC.RowNum_WC = GR.minGeneralRange
						AND ISNULL(GC.MtFCCDetails_IsCancelled, 0) = 0
						AND MtGenerator_Id = GR.MtGenerator_Id)
					AS MinCertificate
				   ,(SELECT
							GC.MtFCCDetails_CertificateId
						FROM #GenCertificates GC
						WHERE GC.RowNum_WC = GR.maxGeneralRange
						AND ISNULL(GC.MtFCCDetails_IsCancelled, 0) = 0
						AND MtGenerator_Id = GR.MtGenerator_Id)
					AS MaxCertificate
				   ,GR.minGeneralRange AS MinRowNumber
				   ,GR.maxGeneralRange AS MaxRowNumber
				FROM cte_GeneralRanges GR


			/*****************************************************************************************    
		    insert into Assignment Details   
		    *****************************************************************************************/



			INSERT INTO [dbo].[MtFCCAAssigmentDetails] (MtFCCADetails_Id, MtFCCAAssigmentDetails_FromCertificate, MtFCCAAssigmentDetails_ToCertificate,
			MtFCCAAssigmentDetails_CreatedBy)
				SELECT
					FCCAD.MtFCCADetails_Id
				   ,cd.MinCertificate
				   ,cd.MaxCertificate
				   ,1
				FROM #tempCertificateDetails cd
				INNER JOIN MtFCCAGenerator FCCAG
					ON cd.MtGeneratorId = FCCAG.MtGenerator_Id
				INNER JOIN MtFCCADetails FCCAD
					ON FCCAG.MtFCCAGenerator_Id = FCCAD.MtFCCAGenerator_Id
				WHERE cd.IsKE = 0
				AND FCCAD.MtPartyRegistration_BuyerId <> @vKEMPId



			INSERT INTO [dbo].[MtFCCAAssigmentDetails] (MtFCCADetails_Id, MtFCCAAssigmentDetails_FromCertificate, MtFCCAAssigmentDetails_ToCertificate,
			MtFCCAAssigmentDetails_CreatedBy)
				SELECT
					FCCAD.MtFCCADetails_Id
				   ,cd.MinCertificate
				   ,cd.MaxCertificate
				   ,1
				FROM #tempCertificateDetails cd
				INNER JOIN MtFCCAGenerator FCCAG
					ON cd.MtGeneratorId = FCCAG.MtGenerator_Id
				INNER JOIN MtFCCADetails FCCAD
					ON FCCAG.MtFCCAGenerator_Id = FCCAD.MtFCCAGenerator_Id
				WHERE cd.IsKE = 1
				AND FCCAD.MtPartyRegistration_BuyerId = @vKEMPId


			/*****************************************************************************************    
		    update the assigned certificates and set their status to 1 (blocked)  
		    *****************************************************************************************/
			UPDATE FCCD
			SET MtFCCDetails_Status = 1
			FROM MtFCCDetails FCCD
			INNER JOIN MtFCCMaster FCC
				ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0
			AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
			AND ISNULL(FCCD.MtFCCDetails_IsCancelled, 0) = 0


			/*****************************************************************************************    
		    insert ranges into fccageneratorDetails  
		    *****************************************************************************************/

			INSERT INTO MtFCCAGeneratorDetails ([MtFCCAGenerator_Id],
			MtFCCAGeneratorDetails_FromCertificate,
			MtFCCAGeneratorDetails_ToCertificate,
			MtFCCAGeneratorDetails_RangeCapacity,
			MtFCCAGeneratorDetails_RangeTotalCertificates,
			MtFCCAGeneratorDetails_IsCancelled,
			MtFCCAGeneratorDetails_CancelledDate,
			MtFCCAGeneratorDetails_CreatedBy)

				SELECT
					GC.MtFCCAGenerator_Id
				   ,MIN(MtFCCDetails_CertificateId)
				   ,MAX(MtFCCDetails_CertificateId)
				   ,((MAX(RowNum_WC) - MIN(RowNum_WC)) + 1) / 10
				   ,MAX(RowNum_WC) - MIN(RowNum_WC) + 1
				   ,MAX(CAST(MtFCCDetails_IsCancelled AS INT)) AS MtFCCDetails_IsCancelled
				   ,GETDATE()
				   ,@pUserId
				FROM #GenCertificates GC
				INNER JOIN MtFCCAGenerator fccag
					ON GC.MtFCCAGenerator_Id = fccag.MtFCCAGenerator_Id
				WHERE fccag.MtFCCAMaster_Id = @pFCCAMasterId
				GROUP BY GC.MtGenerator_Id
						,GC.MtFCCAGenerator_Id
						,partition_seqnum;


		END

		UPDATE FCCA
		SET MtFCCAMaster_ModifiedOn = GETDATE()
		   ,MtFCCAMaster_ModifiedBy = @pUserId
		   ,MtFCCAMaster_Status = 'Executed'
		FROM MtFCCAMaster FCCA
		WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId


		/***************************************************************************    
	 Logs section    
	 ****************************************************************************/

		SET @output = 'Process Execution Completed: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
				ISNULL(MtPartyRegisteration_Name, '')
			FROM MtFCCAMaster fcca
			INNER JOIN MtPartyRegisteration pr
				ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
			WHERE MtFCCAMaster_Id = @pFCCAMasterId);

		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Certificate Administration'
							   ,@CrudOperationName = 'Update'
							   ,@logMessage = @output

	/***************************************************************************    
     Logs section    
    ****************************************************************************/
	END TRY

	BEGIN CATCH

		--- Rollback existing process.  

		EXEC FCCA_Rollback @pFCCAMasterId
						  ,@pUserId;
		--- Update execution status to 'Interrupted'  
		UPDATE FCCA
		SET MtFCCAMaster_ModifiedOn = GETDATE()
		   ,MtFCCAMaster_ModifiedBy = @pUserId
		   ,MtFCCAMaster_Status = 'Interrupted'
		FROM MtFCCAMaster FCCA
		WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();
		RAISERROR (@vErrorMessage, 16, -1);


		/***************************************************************************    
	 Logs section    
	 ****************************************************************************/

		SET @output = 'Process Execution Interrupted: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ' with name: ' + (SELECT
				ISNULL(MtPartyRegisteration_Name, '')
			FROM MtFCCAMaster fcca
			INNER JOIN MtPartyRegisteration pr
				ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
			WHERE MtFCCAMaster_Id = @pFCCAMasterId);

		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Certificate Administration'
							   ,@CrudOperationName = 'Update'
							   ,@logMessage = @output

		/***************************************************************************    
	     Logs section    
	    ****************************************************************************/


		RETURN;
	END CATCH
END
