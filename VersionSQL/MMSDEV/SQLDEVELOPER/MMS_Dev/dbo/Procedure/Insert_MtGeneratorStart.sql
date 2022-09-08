/****** Object:  Procedure [dbo].[Insert_MtGeneratorStart]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE TYPE [dbo].[GeneratorStartUDT] AS TABLE(
    
--    [Date] date,
--	[GeneratorUnitId] decimal(18,0),
--	[NoOfStarts] decimal(18,2),
--	[UnitCost] decimal(18,2) ,
--	[CostDetermined] VARCHAR(MAX),
--	[ValidationStatus] VARCHAR(MAX), 
--	[Reason] VARCHAR(MAX) 
--)
--GO


CREATE PROCEDURE [dbo].[Insert_MtGeneratorStart]
	@fileMasterId decimal(18,0),
	@UserId Int
   , @tblGeneratorStart [dbo].[GeneratorStartUDT] READONLY
	
AS
BEGIN
    SET NOCOUNT ON;
	declare @vMtGeneratorStart_Id Decimal(18,0);

	SELECT @vMtGeneratorStart_Id=ISNUll(MAX(MtGeneratorStart_Id),0) FROM MtGeneratorStart  
	

  
    INSERT INTO MtGeneratorStart
	(
	 MtGeneratorStart_Id
	,MtSOFileMaster_Id
	,MtGenerationUnit_Id
	,MtGeneratorStart_Date
	,MtGeneratorStart_NoOfStarts
	,MtGeneratorStart_UnitCost
	,MtGeneratorStart_CostDetermined
	,MtGeneratorStart_CreatedBy
	,MtGeneratorStart_CreatedOn
	,MtGeneratorStart_IsDeleted
	)
    SELECT 
	 @vMtGeneratorStart_Id +ROW_NUMBER() OVER(order by [GeneratorUnitId]) AS num_row 
	 ,@fileMasterId
	 ,[GeneratorUnitId]
	 ,[Date]
	 ,[NoOfStarts]
	 ,[UnitCost]
	 ,[CostDetermined]
	 ,@UserId
	 ,GETUTCDATE()
	 ,0
	FROM @tblGeneratorStart


	 UPDATE 
		MtSOFileMaster 
	 set
		LuStatus_Code= 'DRAF' 
	WHERE 
		MtSOFileMaster_Id = @fileMasterId
END
