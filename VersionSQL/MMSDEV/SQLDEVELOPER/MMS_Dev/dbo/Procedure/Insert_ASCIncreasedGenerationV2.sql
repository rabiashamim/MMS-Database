/****** Object:  Procedure [dbo].[Insert_ASCIncreasedGenerationV2]    Committed by VersionSQL https://www.versionsql.com ******/

  
CREATE   PROCEDURE [dbo].[Insert_ASCIncreasedGenerationV2]  
 @fileMasterId decimal(18,0),  
 @UserId Int  
    
AS  
BEGIN  
    SET NOCOUNT ON;  
 declare @vMtAscIG_Id Decimal(18,0);  
  
 SELECT @vMtAscIG_Id=ISNUll(MAX(MtAscIG_Id),0)+1 FROM MtAscIG    

INSERT INTO [dbo].MtAscIG  
(
 MtAscIG_Id
,MtSOFileMaster_Id
,MtGenerationUnit_Id
,MtAscIG_Date
,MtAscIG_Hour
,MtAscIG_VariableCost
,MtAscIG_CreatedBy
,MtAscIG_CreatedOn
,MtAscIG_IsDeleted
,EnergyProduceIfNoAncillaryServices
,Reason
,MTAscIG_NtdcDateTime
,MtAscIG_RowNumber
)
 SELECT   
@vMtAscIG_Id +ROW_NUMBER() OVER(order by MtAscIG_Date) AS num_row   
,MtSOFileMaster_Id
,MtGenerationUnit_Id
,MtAscIG_Date
,MtAscIG_Hour
,MtAscIG_VariableCost
,@UserId  
,GETUTCDATE() 
,0
,EnergyProduceIfNoAncillaryServices
,Reason
,MTAscIG_NtdcDateTime
,MtAscIG_RowNumber 
FROM   
[MtAscIG_Interface]    
WHERE   
MtSOFileMaster_Id=@fileMasterId  
  
  
  
 --select * from [MtAvailibilityData_Interface] WHERE MtSOFileMaster_Id=295  
 --select *  from [MtAvailibilityData] WHERE MtSOFileMaster_Id=295  
   
END  
