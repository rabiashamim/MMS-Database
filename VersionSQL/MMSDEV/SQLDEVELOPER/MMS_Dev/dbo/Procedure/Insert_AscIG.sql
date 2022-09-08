/****** Object:  Procedure [dbo].[Insert_AscIG]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[AscIG] AS TABLE(    
        
--    [Date] date,    
--    [Hour] [varchar](5),    
-- [GeneratorUnitId] decimal(18,0),    
-- [VariableCost] decimal(18,2) ,    
-- [ExpectedEnergy] decimal(18,2),
-- [Reason] varchar(max)
--)    
--GO    
    
    
CREATE PROCEDURE [dbo].[Insert_AscIG]    
 @fileMasterId decimal(18,0)    
,@UserId Int    
,@tblAscIG [dbo].[AscIG] READONLY    
     
AS    
BEGIN    
    SET NOCOUNT ON;    
 declare @vMtAscIG_Id Decimal(18,0);    
    
 SELECT @vMtAscIG_Id=ISNUll(MAX(MtAscIG_Id),0) FROM MtAscIG      
     
    
      
    INSERT INTO MtAscIG    
 (    
  MtAscIG_Id    
 ,MtSOFileMaster_Id    
 ,MtGenerationUnit_Id    
 ,MtAscIG_Date    
 ,MtAscIG_Hour    
 ,EnergyProduceIfNoAncillaryServices    
 ,MtAscIG_VariableCost
 ,Reason
 ,MtAscIG_CreatedBy    
 ,MtAscIG_CreatedOn    
 ,MtAscIG_IsDeleted    
 )    
    SELECT     
  @vMtAscIG_Id +ROW_NUMBER() OVER(order by [Hour]) AS num_row     
  ,@fileMasterId    
  ,[GeneratorUnitId]    
  , [Date]    
  ,[Hour]    
  ,[ExpectedEnergy]    
  ,[VariableCost]    
  , Reason  
  ,@UserId    
  ,GETUTCDATE()    
  ,0    
 FROM @tblAscIG    
  
  
  
 UPDATE   
 MtSOFileMaster   
 set  
 LuStatus_Code= 'DRAF'   
WHERE   
 MtSOFileMaster_Id = @fileMasterId  
  
END
