/****** Object:  Procedure [dbo].[Insert_DeterminationSecurityCover_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Alina Javed
-- CREATE date: 16 June 2023
-- Description: 
-- ============================================= 
CREATE   PROCEDURE dbo.Insert_DeterminationSecurityCover_Interface @soFileMasterId DECIMAL(18, 0),
@UserId INT,
--@pIsValid bit= 0,
@MTDeterminationofSecurityCover [dbo].[MTDeterminationofSecurityCover] READONLY
AS

BEGIN
BEGIN TRY

	INSERT INTO [dbo].[MTDeterminationofSecurityCover_Interface] ([MTDeterminationofSecurityCover_Interface_RowNumber]
	, [MtSOFileMaster_Id]
	, [MTDeterminationofSecurityCover_Interface_ContractType] 
	, [MTDeterminationofSecurityCover_Interface_Buyer_Id]
	, [MTDeterminationofSecurityCover_Interface_Seller_Id]
	,[MTDeterminationofSecurityCover_Interface_Year]
	,[MTDeterminationofSecurityCover_Interface_Month]
	,[MTDeterminationofSecurityCover_Interface_DSP]
	,[MTDeterminationofSecurityCover_Interface_LineVoltage]
	,[MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh]
	,[MTDeterminationofSecurityCover_Interface_LoadProfileBuyer]	
	,[MTDeterminationofSecurityCover_Interface_FixedQtyContract] 
	,[MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice] 
	,[MTDeterminationofSecurityCover_Interface_IsValid]
	,[MTDeterminationofSecurityCover_Interface_Message]
	
	)
		SELECT
			ROW_NUMBER() OVER (ORDER BY [BuyerId], [SellerId]) AS num_row
		   ,@soFileMasterId
		   ,[ContractType] 
		  , [BuyerId] 
			,[SellerId] 
			,[Year] 
			,[Month] 
			,[DSP]
			,[LineVoltage]
			,[GeneratorDispatchProfileforMonth_MWh]
			,[LoadProfileBPC_MWh] [nvarchar]
			,[FixedQtyContract] [nvarchar]
			,[MonthlyAvgMarginalPrice_PKR/MWh]	   
		   ,1
		   ,''
		FROM @MTDeterminationofSecurityCover

		update MtSOFileMaster set TotalRecords=(select count(1) from [dbo].[MTDeterminationofSecurityCover_Interface]
		where [MtSOFileMaster_Id]=@soFileMasterId) where [MtSOFileMaster_Id]=@soFileMasterId

		EXEC [dbo].[DeterminationSecurityCover_Validation] @soFileMasterId,     
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
