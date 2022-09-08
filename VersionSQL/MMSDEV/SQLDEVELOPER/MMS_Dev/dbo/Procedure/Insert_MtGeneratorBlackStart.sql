/****** Object:  Procedure [dbo].[Insert_MtGeneratorBlackStart]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[GeneratorBlackStartUDT] AS TABLE(
    
--    [Date] date,
--	[GeneratorUnitId] decimal(18,0),
--	[CapabilityCharges] decimal(18,2),
--	[Remarks] VARCHAR(MAX), 
--	[ValidationStatus] VARCHAR(MAX), 
--	[Reason] VARCHAR(MAX) 
--)
--GO


CREATE PROCEDURE [dbo].[Insert_MtGeneratorBlackStart]
	@fileMasterId decimal(18,0),
	@UserId Int
   , @tblGeneratorBlackStart [dbo].[GeneratorBlackStartUDT] READONLY
	
AS
BEGIN
    SET NOCOUNT ON;
	declare @vMtGeneratorBlackStart_Id Decimal(18,0);

	SELECT @vMtGeneratorBlackStart_Id=ISNUll(MAX(MtGeneratorBS_Id),0) FROM MtGeneratorBS  
	

  
    INSERT INTO MtGeneratorBS
	(
	 MtGeneratorBS_Id				 
	,MtSOFileMaster_Id
	,MtGenerationUnit_Id
	,MtGeneratorBS_Date
	,MtGeneratorBS_BSCharges
	,MtGeneratorBS_CreatedBy
	,MtGeneratorBS_CreatedOn
	,MtGeneratorBS_BSRemarks
	,MtGeneratorBS_IsDeleted
	)
    SELECT 
	 @vMtGeneratorBlackStart_Id +ROW_NUMBER() OVER(order by [GeneratorUnitId]) AS num_row 
	 ,@fileMasterId
	 ,[GeneratorUnitId]
	 ,[Date]
	 ,[CapabilityCharges]
	 ,@UserId
	 ,GETUTCDATE()
	 ,[Remarks]
	 ,0
	FROM @tblGeneratorBlackStart


	 UPDATE 
		MtSOFileMaster 
	 set
		LuStatus_Code= 'DRAF' 
	WHERE 
		MtSOFileMaster_Id = @fileMasterId
END
