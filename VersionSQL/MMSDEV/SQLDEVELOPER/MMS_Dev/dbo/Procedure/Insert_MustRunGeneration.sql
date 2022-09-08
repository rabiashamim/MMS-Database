/****** Object:  Procedure [dbo].[Insert_MustRunGeneration]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[MtMustRunGen_UDT] AS TABLE(
--    [MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
--	[MtMustRunGen_Date] [date] NOT NULL,
--	[MtMustRunGen_Hour] [varchar](5) NOT NULL,
--	[MtMustRunGen_EnergyProduced] [decimal](20, 4) NOT NULL,
--	[MtMustRunGen_VariableCost] [decimal](20, 4) NOT NULL
--)
--GO


CREATE PROCEDURE [dbo].[Insert_MustRunGeneration]
	@fileMasterId decimal(18,0),
	@UserId Int,
   @tblMustRunGen [dbo].[MtMustRunGen_UDT] READONLY
	
AS
BEGIN
    SET NOCOUNT ON;
	declare @vMtMustRunGen_Id Decimal(18,0);

	SELECT @vMtMustRunGen_Id=ISNUll(MAX(MtMustRunGen_Id),0) FROM MtMustRunGen  
	

  INSERT INTO [dbo].[MtMustRunGen]
           (
		   MtMustRunGen_Id
           ,[MtSOFileMaster_Id]
           ,[MtGenerationUnit_Id]
           ,[MtMustRunGen_Date]
           ,[MtMustRunGen_Hour]
           ,[MtMustRunGen_EnergyProduced]
           ,[MtMustRunGen_VariableCost]
           ,[MtMustRunGen_CreatedBy]
           ,[MtMustRunGen_CreatedOn]
           ,[MtMustRunGen_IsDeleted])
   
    SELECT 
	 @vMtMustRunGen_Id +ROW_NUMBER() OVER(order by MtMustRunGen_Date) AS num_row 
	 ,@fileMasterId
	 ,MtGenerationUnit_Id
	 ,MtMustRunGen_Date
	 ,MtMustRunGen_Hour
	 ,MtMustRunGen_EnergyProduced
	 ,MtMustRunGen_VariableCost
	 ,@UserId
	 ,GETUTCDATE()
	 ,0
	FROM @tblMustRunGen
END
