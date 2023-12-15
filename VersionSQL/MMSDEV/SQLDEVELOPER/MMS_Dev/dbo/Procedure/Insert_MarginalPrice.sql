/****** Object:  Procedure [dbo].[Insert_MarginalPrice]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[MtMarginalPrice_UDT] AS TABLE(
    
--    [MtMarginalPrice_Date] date,
--    [MtMarginalPrice_Hour] [varchar](5),
--	[MtMarginalPrice_Price] decimal(18,2)
--)
--GO


CREATE PROCEDURE dbo.Insert_MarginalPrice
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

	 --declare @version int=0;
		-- select @version=MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId

		--  declare @period int=0;
		--  select @period =LuAccountingMonth_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId

		--  declare @pSOFileTemplate int=0;
		--  select @pSOFileTemplate=LuSOFileTemplate_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId

		--  declare @tempname NVARCHAR(MAX)=NULL;
		--  SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate

		--  declare @output VARCHAR(max);
		--	SET @output= @tempname+'submitted for approval. Settlement Period:' +convert(varchar(max),@period) +',Version:' + convert(varchar(max),@version) 

		--		EXEC [dbo].[SystemLogs] 
		--		@user=@UserId,
		--		 @moduleName='Data Management',  
		--		 @CrudOperationName='Create',  
		--		 @logMessage=@output 


END
