/****** Object:  Procedure [dbo].[Insert_AscRG]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[AscRG] AS TABLE(  
      
--    [Date] date,  
--    [Hour] [varchar](5),  
-- [GeneratorUnitId] decimal(18,0),  
-- [GenerationUnitType] [varchar](50),  
-- [VariableCost] decimal(18,2) ,  
-- [ExpectedEnergy] decimal(18,2)   
--)  
--GO  
  
  
CREATE PROCEDURE [dbo].[Insert_AscRG]  
 @fileMasterId decimal(18,0),  
 @UserId Int  
   ,@tblAscRG [dbo].[AscRG] READONLY  
   
AS  
BEGIN  
    SET NOCOUNT ON;  
 declare @vMtAscRG_Id Decimal(18,0);  
  
 SELECT @vMtAscRG_Id=ISNUll(MAX(MtAscRG_Id),0) FROM MtAscRG    
   
  
    
    INSERT INTO MtAscRG  
 (  
  MtAscRG_Id  
 ,MtSOFileMaster_Id  
 ,MtGenerationUnit_Id  
 ,MtAscRG_Date  
 ,MtAscRG_Hour  
 ,MtAscRG_ExpectedEnergy  
 ,MtAscRG_VariableCost  
 ,GenerationUnitTypeARE  
 ,MtAscRG_CreatedBy  
 ,MtAscRG_CreatedOn  
 ,MtAscRG_IsDeleted  
 )  
    SELECT   
  @vMtAscRG_Id +ROW_NUMBER() OVER(order by [Hour]) AS num_row   
  ,@fileMasterId  
  ,[GeneratorUnitId]  
  , [Date]  
  ,[Hour]  
  ,ISNULL([ExpectedEnergy],0)  
  ,ISNULL([VariableCost],0)  
  ,[GenerationUnitType]  
  ,@UserId  
  ,GETUTCDATE()  
  ,0  
 FROM @tblAscRG  



 UPDATE 
	MtSOFileMaster 
 set
	LuStatus_Code= 'DRAF' 
WHERE 
	MtSOFileMaster_Id = @fileMasterId

END
