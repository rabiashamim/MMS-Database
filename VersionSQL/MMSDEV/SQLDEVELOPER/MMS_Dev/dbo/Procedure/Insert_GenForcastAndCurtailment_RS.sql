/****** Object:  Procedure [dbo].[Insert_GenForcastAndCurtailment_RS]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  ALI IMRAN | Alina Javed  
-- CREATE date: 30 march 2023  
-- Description:   
-- =============================================   
-- Insert_GenForcastAndCurtailment 948,1  
CREATE   PROCEDURE dbo.Insert_GenForcastAndCurtailment_RS   
 @pSoFileMasterId DECIMAL(18, 0),  
@pUserId INT=1  
, @pIsUseForSettlement BIT    
AS  
 BEGIN  


 BEGIN TRY   
 INSERT INTO [dbo].[MTGenForcastAndCurtailment] ([MTGenForcastAndCurtailment_RowNumber]  
 , [MtSOFileMaster_Id]  
 , [MtGenerator_Id]  
 , [MTGenForcastAndCurtailment_Date]  
 , [MTGenForcastAndCurtailment_Hour]  
 , [MTGenForcastAndCurtailment_Forecast_MW]   
 , [MTGenForcastAndCurtailment_Curtailemnt_MW]   
 --, [MTGenForcastAndCurtailment_CreatedBy]  
 , [MTGenForcastAndCurtailment_CreatedOn]  
 )  
  SELECT  
  
   MTGenForcastAndCurtailment_Interface_RowNumber  
     ,MtSOFileMaster_Id  
     ,MtGenerator_Id  
     ,MTGenForcastAndCurtailment_Interface_Date  
     ,MTGenForcastAndCurtailment_Interface_Hour  
     ,isnull(MTGenForcastAndCurtailment_Interface_Forecast_MW ,0) 
     ,isnull(MTGenForcastAndCurtailment_Interface_Curtailemnt_MW ,0)  
     --,@pUserId  
     ,GETDATE()  
  FROM [dbo].[MTGenForcastAndCurtailment_Interface]  
  WHERE MtSOFileMaster_Id = @pSoFileMasterId  
  and MTGenForcastAndCurtailment_Interface_Forecast_MW is not null
  
  
UPDATE MtSOFileMaster  
SET LuStatus_Code = 'DRAF'  
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement  
WHERE MtSOFileMaster_Id = @pSoFileMasterId;  
  
  
  
DELETE FROM MTGenForcastAndCurtailment_Interface  
WHERE MtSOFileMaster_Id = @pSoFileMasterId;  
  
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
