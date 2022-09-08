/****** Object:  Procedure [dbo].[Insert_GenerationAvailabilityData]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[MtAvailabilityData_UDT] AS TABLE(
    
--    MtAvailibilityData_Date date,
--    MtAvailibilityData_Hour [varchar](5),
--	MtGenerationUnit_Id decimal(18,0),
--	MtAvailibilityData_ActualCapacity decimal(18,0),
--	MtAvailibilityData_AvailableCapacityASC decimal(18,0)
--)
--GO


CREATE PROCEDURE [dbo].[Insert_GenerationAvailabilityData]
	@fileMasterId decimal(18,0),
	@UserId Int,
   @tblAvailabilityData [dbo].[MtAvailabilityData_UDT] READONLY
	
AS
BEGIN
    SET NOCOUNT ON;
	declare @vMtAvailabilityData_Id Decimal(18,0);

	SELECT @vMtAvailabilityData_Id=ISNUll(MAX(MtAvailibilityData_Id),0)+1 FROM MtAvailibilityData  
	

  INSERT INTO [dbo].MtAvailibilityData
           (MtAvailibilityData_Id
           ,[MtSOFileMaster_Id]
           ,MtAvailibilityData_Date
           ,[MtAvailibilityData_Hour]
		   ,MtGenerationUnit_Id
           ,[MtAvailibilityData_AvailableCapacityASC]
		   ,[MtAvailibilityData_ActualCapacity]
           ,MtAvailibilityData_CreatedBy
           ,MtAvailibilityData_CreatedOn
           ,MtAvailibilityData_IsDeleted)
   
    SELECT 
	 @vMtAvailabilityData_Id +ROW_NUMBER() OVER(order by MtAvailibilityData_Date) AS num_row 
	 ,@fileMasterId,
		MtAvailibilityData_Date,
		MtAvailibilityData_Hour,
		MtGenerationUnit_Id,
		MtAvailibilityData_AvailableCapacityASC,
		MtAvailibilityData_ActualCapacity
		,@UserId
	 ,GETUTCDATE()
	 ,0
	FROM @tblAvailabilityData
END
