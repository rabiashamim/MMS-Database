/****** Object:  Procedure [dbo].[Insert_GenForcastAndCurtailment_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALI IMRAN | Alina Javed
-- CREATE date: 30 march 2023
-- Description: 
-- ============================================= 
CREATE  PROCEDURE dbo.Insert_GenForcastAndCurtailment_Interface @soFileMasterId DECIMAL(18, 0),
@UserId INT,
--@pIsValid bit= 0,
@MtGenForcastAndCurtailment [dbo].[MTGenForcastAndCurtailment] READONLY
AS

BEGIN
BEGIN TRY

	INSERT INTO [dbo].[MTGenForcastAndCurtailment_Interface] ([MTGenForcastAndCurtailment_Interface_RowNumber]
	, [MtSOFileMaster_Id]
	, [MtGenerator_Id]
	, [MTGenForcastAndCurtailment_Interface_Date]
	, [MTGenForcastAndCurtailment_Interface_Hour]
	, [MTGenForcastAndCurtailment_Interface_Forecast_MW]
	, [MTGenForcastAndCurtailment_Interface_Curtailemnt_MW]
	,MTGenForcastAndCurtailment_Interface_IsValid
	,MTGenForcastAndCurtailment_Interface_Message)
		SELECT
			ROW_NUMBER() OVER (ORDER BY [Date],[Hour],[GeneratorId]) AS num_row
		   ,@soFileMasterId
		   ,GeneratorId
		   ,[Date]
		   ,[Hour]
		   ,[Forecast]
		   ,[Curtailemnt]
		   ,1
		   ,''
		FROM @MtGenForcastAndCurtailment

		update MtSOFileMaster set TotalRecords=(select count(1) from [dbo].[MTGenForcastAndCurtailment_Interface]
		where [MtSOFileMaster_Id]=@soFileMasterId) where [MtSOFileMaster_Id]=@soFileMasterId

		EXEC [dbo].[GenForcastAndCurtailmentValidation] @soFileMasterId,     
             @userID;  
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
