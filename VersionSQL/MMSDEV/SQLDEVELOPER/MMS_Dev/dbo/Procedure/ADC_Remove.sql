/****** Object:  Procedure [dbo].[ADC_Remove]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALI IMRAN
-- CREATE date: 7 march 2023
-- ALTER date: 
-- Description: 
-- ============================================= 

CREATE     PROCEDURE dbo.ADC_Remove @pADC_Id DECIMAL(18, 0)
, @pUserId DECIMAL(18, 0)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY   


		UPDATE [dbo].[MtAnnualDependableCapacityADC]
		SET MtAnnualDependableCapacityADC_IsDeleted = 1
		    ,MtAnnualDependableCapacityADC_ModifiedBy=@pUserId
			,MtAnnualDependableCapacityADC_ModifiedOn=GETDATE()

		WHERE MtAnnualDependableCapacityADC_Id = @pADC_Id
	
/********************************************************************************************/
	END TRY
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;


END
