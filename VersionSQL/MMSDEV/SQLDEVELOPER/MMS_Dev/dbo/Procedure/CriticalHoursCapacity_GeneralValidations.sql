/****** Object:  Procedure [dbo].[CriticalHoursCapacity_GeneralValidations]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================              
-- Author: Ammama Gill                         
-- CREATE date:  14/12/2022                               
-- ALTER date:                                 
-- Reviewer:                                
-- Description: Additional Validations for Critical hours.                           
-- =============================================                                 
-- =============================================         

CREATE PROCEDURE CriticalHoursCapacity_GeneralValidations @pSoFileMaster_Id DECIMAL(18, 0),
@pUser_Id INT

AS
BEGIN
	BEGIN TRY


		DECLARE @vValidationMessage NVARCHAR(MAX) = '';

		--50 entries   

		SELECT
			@vValidationMessage =
			mchci.MtCriticalHoursCapacity_SOUnitId +
			': Critical Hours for the settlement period should be 50. '
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtCriticalHoursCapacity_IsDeleted = 0
		GROUP BY mchci.MtCriticalHoursCapacity_SOUnitId
		HAVING COUNT(1) <> 50

		IF @vValidationMessage <> ''
		BEGIN
			UPDATE MtSOFileMaster
			SET InvalidRecords = ISNULL(InvalidRecords, 0) + 1
			WHERE MtSOFileMaster_Id = @pSoFileMaster_Id
			AND ISNULL(MtSOFileMaster_IsDeleted, 0) = 0
			AND ISNULL(InvalidRecords, 0) = 0;
		END

		SELECT
			@vValidationMessage;


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
