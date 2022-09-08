/****** Object:  Procedure [dbo].[Insert_ASCReducedGenerationV2]    Committed by VersionSQL https://www.versionsql.com ******/

    
CREATE   PROCEDURE [dbo].[Insert_ASCReducedGenerationV2]    
 @fileMasterId decimal(18,0),    
 @UserId Int    
      
AS    
BEGIN    
    SET NOCOUNT ON;    
 declare @vMtAscRG_Id Decimal(18,0);    
    
 SELECT @vMtAscRG_Id=ISNUll(MAX(MtAscRG_Id),0)+1 FROM MtAscRG      
  
INSERT INTO [dbo].MtAscRG    
(  
 MtAscRG_Id
,MtSOFileMaster_Id
,MtGenerationUnit_Id
,MtAscRG_Date
,MtAscRG_Hour
,MtAscRG_ExpectedEnergy
,MtAscRG_VariableCost
,MtAscRG_CreatedBy
,MtAscRG_CreatedOn
,MtAscRG_IsDeleted
,GenerationUnitTypeARE
,MTAscRG_NtdcDateTime
,MtAscRG_RowNumber 
)  
 SELECT     
 @vMtAscRG_Id +ROW_NUMBER() OVER(order by MtAscRG_Date) AS num_row     
,MtSOFileMaster_Id
,MtGenerationUnit_Id
,MtAscRG_Date
,MtAscRG_Hour
,MtAscRG_ExpectedEnergy
,MtAscRG_VariableCost
,@UserId
,GETUTCDATE()  
,0
,GenerationUnitTypeARE
,MTAscRG_NtdcDateTime
,MtAscRG_RowNumber 
FROM     
[MtAscRG_Interface]      
WHERE     
MtSOFileMaster_Id=@fileMasterId    
    
    
    
 --select * from [MtAvailibilityData_Interface] WHERE MtSOFileMaster_Id=295    
 --select *  from [MtAvailibilityData] WHERE MtSOFileMaster_Id=295    
     
END 
