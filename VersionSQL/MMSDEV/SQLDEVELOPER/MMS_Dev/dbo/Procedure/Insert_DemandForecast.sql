/****** Object:  Procedure [dbo].[Insert_DemandForecast]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  Alina Javed  
-- CREATE date: 30 march 2023  
-- Description:   
-- =============================================   
-- Insert_GenForcastAndCurtailment 948,1  
CREATE   PROCEDURE dbo.Insert_DemandForecast   
 @pSoFileMasterId DECIMAL(18, 0),  
@pUserId INT=1  
, @pIsUseForSettlement BIT    
AS  
 BEGIN  
 BEGIN TRY   
 INSERT INTO [dbo].[MTDemandForecast] ([MTDemandForecast_RowNumber]  
 , [MtSOFileMaster_Id]  
 , [MtParty_Id]  
 , [MTDemandForecast_Year]  
 , [MTDemandForecast_Max_Demand_during_Peakhours_MW]  
 , [MTDemandForecast_CreatedBy]  
 , [MTDemandForecast_CreatedOn]  
 )  
  SELECT  
  
   MTDemandForecast_Interface_RowNumber  
     ,MtSOFileMaster_Id  
     ,MtParty_Id  
     ,MTDemandForecast_Interface_Year  
     ,MTDemandForecast_Interface_Max_Demand_during_peakhours_MW  
     ,@pUserId  
     ,GETDATE()  
  FROM [dbo].[MTDemandForecast_Interface]  
  WHERE MtSOFileMaster_Id = @pSoFileMasterId  
  
  
UPDATE MtSOFileMaster  
SET LuStatus_Code = 'DRAF'  
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement  
WHERE MtSOFileMaster_Id = @pSoFileMasterId;  
  
  
  
--DELETE FROM MTDemandForecast_Interface  
--WHERE MtSOFileMaster_Id = @pSoFileMasterId;  
  
---------------- sp for validations of capacity obligation---------------  
EXEC [dbo].[CapacityObligations_Execute] @pSoFileMasterId, @pUserId;  


--------------------------------------------------------------------------
  
END TRY  
BEGIN CATCH  
DECLARE @vErrorMessage VARCHAR(MAX) = '';
        SELECT
            @vErrorMessage = ERROR_MESSAGE();

 

        RAISERROR (@vErrorMessage, 16, -1);
        RETURN;
--SELECT  
-- ERROR_NUMBER() AS ErrorNumber  
--   ,ERROR_STATE() AS ErrorState  
--   ,ERROR_SEVERITY() AS ErrorSeverity  
--   ,ERROR_PROCEDURE() AS ErrorProcedure  
--   ,ERROR_LINE() AS ErrorLine  
--   ,ERROR_MESSAGE() AS ErrorMessage;  
END CATCH  
END
