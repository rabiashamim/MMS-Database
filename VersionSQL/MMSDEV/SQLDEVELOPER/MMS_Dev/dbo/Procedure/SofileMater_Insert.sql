/****** Object:  Procedure [dbo].[SofileMater_Insert]    Committed by VersionSQL https://www.versionsql.com ******/

  
CREATE PROCEDURE [dbo].[SofileMater_Insert]    
 @pSettlementPeriod INT    
,@pDescription NVARCHAR(MAX)    
,@pSOFileTemplate INT    
,@pFilename NVARCHAR(max)    
,@pPath NVARCHAR(MAX)    
AS    
BEGIN    
Declare @MtSOFileMaster_Id int ;    
SELECT  @MtSOFileMaster_Id =IsNull(MAX( [MtSOFileMaster_Id] ) + 1,1) from MtSOFileMaster    
    
INSERT INTO MtSOFileMaster(    
 MtSOFileMaster_Id    
 ,LuSOFileTemplate_Id    
 ,LuAccountingMonth_Id    
 ,MtSOFileMaster_FileName    
 ,MtSOFileMaster_FilePath,    
 MtSOFileMaster_IsUseForSettlement,    
 LuStatus_Code,    
 MtSOFileMaster_Version,    
 MtSOFileMaster_Description,    
 MtSOFileMaster_CreatedBy,    
 MtSOFileMaster_CreatedOn)    
VALUES(     
@MtSOFileMaster_Id    
,@pSOFileTemplate    
,@pSettlementPeriod    
,@pFilename    
,@pPath    
,0    
,'UPL'    
,(    
    select (ISNULL(max(MtSOFileMaster_Version),0)+1)    
    from MtSOFileMaster     
    where LuSOFileTemplate_Id=@pSOFileTemplate     
    and LuAccountingMonth_Id=@pSettlementPeriod     
    and isnull(MtSOFileMaster_IsDeleted,0)=0     
    and LuStatus_Code='APPR')    
,@pDescription,1,GETUTCDATE()     
)    
    
SELECT @MtSOFileMaster_Id     
    
END
