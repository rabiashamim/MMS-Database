/****** Object:  Procedure [dbo].[Insert_DemandForecast_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Alina Javed
-- CREATE date: 16 May 2023
-- Description: 
-- ============================================= 
CREATE   PROCEDURE dbo.Insert_DemandForecast_Interface @soFileMasterId DECIMAL(18, 0),
@UserId INT,
--@pIsValid bit= 0,
@MtDemandForecast [dbo].[MTDemandForecast] READONLY
AS

BEGIN
BEGIN TRY

	INSERT INTO [dbo].[MTDemandForecast_Interface] ([MTDemandForecast_Interface_RowNumber]
	, [MtSOFileMaster_Id]
	, [MtParty_Id]
	, [MTDemandForecast_Interface_Year]
	, [MTDemandForecast_Interface_Max_Demand_during_peakhours_MW]
	,[MTDemandForecast_Interface_IsValid]
	,[MTDemandForecast_Interface_Message])
		SELECT
			ROW_NUMBER() OVER (ORDER BY [GeneratorId]) AS num_row
		   ,@soFileMasterId
		   ,[GeneratorId]
		   ,[YEAR]
		   ,[Max_Demand_during_Peakhours_MW]		   
		   ,1
		   ,''
		FROM @MtDemandForecast

		update MtSOFileMaster set TotalRecords=(select count(1) from [dbo].[MTDemandForecast_Interface]
		where [MtSOFileMaster_Id]=@soFileMasterId) where [MtSOFileMaster_Id]=@soFileMasterId

		EXEC [dbo].[DemandForecasttValidation] @soFileMasterId,     
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
