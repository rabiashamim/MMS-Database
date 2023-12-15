/****** Object:  Procedure [dbo].[CapacityObligations_Rollback]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ================================================================================      
-- Author:  Ammama Gill   
-- CREATE date: 19 May 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     

CREATE   PROCEDURE dbo.CapacityObligations_Rollback (@pSoFileMasterId DECIMAL(18, 0), @pUserId INT)
AS
BEGIN
	DELETE FROM MTDemandForecast
	WHERE MtSOFileMaster_Id = @pSoFileMasterId

	DELETE FROM MtCapacityObligationsDetails
	WHERE MtSOFileMaster_Id = @pSoFileMasterId

	UPDATE MtSOFileMaster
	SET LuStatus_Code = 'UPL'
	   ,MtSOFileMaster_ModifiedBy = @pUserId
	   ,MtSOFileMaster_ModifiedOn = GETDATE()
	WHERE MtSOFileMaster_Id = @pSoFileMasterId
END
