/****** Object:  Procedure [dbo].[SecurityCoverBMC_Validations]    Committed by VersionSQL https://www.versionsql.com ******/

/************************************************************/
-- =============================================                              
-- Author: Sadaf Malik  
-- CREATE date:  3/01/2023                                               
-- ALTER date:                                                 
-- Reviewer:                                                
-- Description: Validate Security Cover BMC Data.                                          
-- =============================================                                                 
-- =============================================                         


CREATE PROCEDURE dbo.SecurityCoverBMC_Validations @pSoFileMaster_Id DECIMAL(18, 0),
@pUser_Id INT

AS
BEGIN
	BEGIN TRY

		DECLARE @vYear INT;

		SELECT
			@vYear = lam.LuAccountingMonth_Year
		FROM MtSOFileMaster msm
		INNER JOIN LuAccountingMonth lam
			ON msm.LuAccountingMonth_Id = lam.LuAccountingMonth_Id
		WHERE msm.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(lam.LuAccountingMonth_IsDeleted, 0) = 0
		AND ISNULL(msm.MtSOFileMaster_IsDeleted, 0) = 0;

		UPDATE mch
		SET MtSecurityCoverMP_Message =
		CASE
			WHEN ISNULL(mch.MtPartyRegisteration_Id, '') = '' THEN 'Party Id cannot be empty. '
			ELSE CASE

					WHEN ISNUMERIC(mch.MtPartyRegisteration_Id) = 0 THEN 'Invalid Party Id. '
					ELSE CASE
							WHEN EXISTS (SELECT
										mgu.MtPartyRegisteration_Id
									FROM MtPartyRegisteration mgu
									WHERE mch.MtPartyRegisteration_Id = mgu.MtPartyRegisteration_Id
									AND LuStatus_Code_Applicant IN ('AACT', 'APP')
									AND ISNULL(mgu.isDeleted, 0) = 0) THEN ''
							ELSE 'Party Id does not exist. '
						END
				END

		END +
		CASE
			WHEN ISNULL(mch.MtSecurityCoverMP_SubmittedSecurityCover, '') = '' THEN 'Submitted security cover value cannot be empty. '
			WHEN ISNUMERIC(mch.MtSecurityCoverMP_SubmittedSecurityCover) = 0 THEN 'Invalid submitted security cover. '
			WHEN CAST(REPLACE(mch.MtSecurityCoverMP_SubmittedSecurityCover,',','') AS DECIMAL(38, 13)) < 0 THEN 'Submitted Security Cover Amount cannot be negative. '
			ELSE ''
		END +
		CASE
			WHEN ISNULL(mch.MtSecurityCoverMP_RequiredSecurityCover, '') = '' THEN 'Required security cover value cannot be empty. '
			WHEN ISNUMERIC(mch.MtSecurityCoverMP_RequiredSecurityCover) = 0 THEN 'Invalid required security cover. '
			WHEN CAST(REPLACE(mch.MtSecurityCoverMP_RequiredSecurityCover,',','')AS DECIMAL(38, 13)) < 0 THEN 'Required Security Cover Amount cannot be negative. '
			ELSE ''
		END

		FROM MtSecurityCoverMP_Interface mch
		WHERE mch.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(mch.MtSecurityCoverMP_IsDeleted,0) = 0;


		UPDATE mch
		SET mch.MtSecurityCoverMP_Message = ISNULL(mch.MtSecurityCoverMP_Message, '') + ' Duplicate Party Id.'
		FROM MtSecurityCoverMP_Interface mch
		INNER JOIN (SELECT
				COUNT(1) AS count1
			   ,MtPartyRegisteration_Id
			FROM MtSecurityCoverMP_Interface mch
			WHERE mch.MtSOFileMaster_Id = @pSoFileMaster_Id
			AND mch.MtSecurityCoverMP_IsDeleted = 0
			AND ISNUMERIC(mch.MtPartyRegisteration_Id) = 1
			AND ISNULL(mch.MtPartyRegisteration_Id, '') <> ''
			GROUP BY mch.MtPartyRegisteration_Id
			HAVING COUNT(1) > 1) t
			ON t.MtPartyRegisteration_Id = mch.MtPartyRegisteration_Id
		;

		------------------------- update interface table. Set isvalid 0.      

		UPDATE MtSecurityCoverMP_Interface
		SET MtSecurityCoverMP_IsValid = 0
		WHERE MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(MtSecurityCoverMP_Message, '') <> ''
		AND MtSecurityCoverMP_IsDeleted = 0;


		------------------ Set valid/invalid count------------      
		DECLARE @vInvalidCount INT
			   ,@vTotalCount INT;
		SELECT
			@vInvalidCount = COUNT(*)
		FROM MtSecurityCoverMP_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtSecurityCoverMP_IsDeleted = 0
		AND mchci.MtSecurityCoverMP_Message <> '';

		SELECT
			@vTotalCount = COUNT(*)
		FROM MtSecurityCoverMP_Interface machci
		WHERE machci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND machci.MtSecurityCoverMP_IsDeleted = 0

		UPDATE MtSOFileMaster
		SET InvalidRecords = @vInvalidCount
		   ,TotalRecords = @vTotalCount
		WHERE MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(MtSOFileMaster_IsDeleted, 0) = 0


		SELECT
			@vInvalidCount AS InvalidCount
		   ,@vTotalCount AS ValidCount;


	END TRY
	BEGIN CATCH

		SELECT
			ERROR_NUMBER() AS ErrorNumber
		   ,ERROR_STATE() AS ErrorState
		   ,ERROR_SEVERITY() AS ErrorSeverity
		   ,ERROR_PROCEDURE() AS ErrorProcedure
		   ,ERROR_LINE() AS ErrorLine
		   ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH

END
