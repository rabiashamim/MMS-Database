/****** Object:  Procedure [dbo].[Insert_MarginalPrice]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[MtMarginalPrice_UDT] AS TABLE(
    
--    [MtMarginalPrice_Date] date,
--    [MtMarginalPrice_Hour] [varchar](5),
--	[MtMarginalPrice_Price] decimal(18,2)
--)
--GO


CREATE PROCEDURE [dbo].[Insert_MarginalPrice]
	@fileMasterId decimal(18,0),
	@UserId Int,
   @tblMarginalPrice [dbo].[MtMarginalPrice_UDT] READONLY
	
AS
BEGIN
    SET NOCOUNT ON;
	declare @vMtMarginalPrice_Id Decimal(18,0);

	SELECT @vMtMarginalPrice_Id=ISNUll(MAX(MtMarginalPrice_Id),0) FROM MtMarginalPrice  
	

  INSERT INTO [dbo].[MtMarginalPrice]
           ([MtMarginalPrice_Id]
           ,[MtSOFileMaster_Id]
           ,[MtMarginalPrice_Date]
           ,[MtMarginalPrice_Hour]
           ,[MtMarginalPrice_Price]
           ,[MtMarginalPrice_CreatedBy]
           ,[MtMarginalPrice_CreatedOn]
           ,[MtMarginalPrice_IsDeleted])
   
    SELECT 
	 @vMtMarginalPrice_Id +ROW_NUMBER() OVER(order by [MtMarginalPrice_Date]) AS num_row 
	 ,@fileMasterId
	 , [MtMarginalPrice_Date]
	 ,[MtMarginalPrice_Hour]
	 ,[MtMarginalPrice_Price]
	 ,@UserId
	 ,GETUTCDATE()
	 ,0
	FROM @tblMarginalPrice
END
