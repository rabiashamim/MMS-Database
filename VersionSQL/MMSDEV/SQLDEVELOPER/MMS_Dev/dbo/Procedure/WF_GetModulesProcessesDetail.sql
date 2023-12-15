/****** Object:  Procedure [dbo].[WF_GetModulesProcessesDetail]    Committed by VersionSQL https://www.versionsql.com ******/

/***************************************    
  Sadaf Malik    
  13-Feb-2023    
*****************************************/    
CREATE  PROCEDURE dbo.WF_GetModulesProcessesDetail    
@pRuModulesProcess_Id as int,    
@pRuModulesProcessDetails_Id as int=0    
AS BEGIN    
    
SELECT    
RM.[RuModulesProcessDetails_Id]     
,RM.[RuModulesProcess_Id]    
,RM.[RuModulesProcessDetails_ColumnName]    
,RM.[RuModulesProcessDetails_Label]  
,RM.[RuModulesProcessDetails_IsSubject]  
,RM.[RuModulesProcessDetails_IsWhere]  
,RM.[RuModulesProcess_ShowOnScreen]
    
FROM RuModulesProcessDetails RM    
where ISNULL(RuModulesProcessDetails_IsDeleted,0)=0    
AND (    
 RM.RuModulesProcess_Id=@pRuModulesProcess_Id    
)    
    
AND (    
@pRuModulesProcessDetails_Id=0 or RM.RuModulesProcessDetails_Id=@pRuModulesProcessDetails_Id    
)    
    
END
