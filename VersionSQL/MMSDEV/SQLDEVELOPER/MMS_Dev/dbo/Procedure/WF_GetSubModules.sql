/****** Object:  Procedure [dbo].[WF_GetSubModules]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================              
-- Author:  <Aymen Khalid>              
-- Create date: <22-02-2022>              
-- Description: <Returns the period typeSub Modules of given modules>              
-- =============================================            
CREATE PROCEDURE dbo.WF_GetSubModules          
@pRuModules_Id as int        
          
AS BEGIN          
          
 IF (@pRuModules_Id = 4) --Settlements        
 BEGIN        
  SELECT       
   spd.SrProcessDef_ID AS SubprocessID,      
    CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name) AS SubprocessName            
  FROM SrStatementDef SSD        
  INNER JOIN SrProcessDef SPD        
   ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID        
  ORDER by 2        
 END        
 --ELSE IF(@pRuModules_Id = 3) --Data Management        
 --BEGIN        
 -- SELECT      
 -- LuSOFileTemplate_Id AS SubprocessID,      
 --  LuSOFileTemplate_Name AS SubprocessName        
 -- FROM         
 --  LuSOFileTemplate         
 -- WHERE isnull(LuSOFileTemplate_IsDeleted,0)=0        
 --  ORDER by 2        
 --END  
 ELSE -- all other modules  
 BEGIN  
  SELECT   
 RuWorkFlowCustomProcess_ProcessId AS SubprocessID,   
 RuWorkFlowCustomProcess_ProcessName  AS SubprocessName  
  FROM   
 RuWorkFlowCustomProcess   
  WHERE    
 RuModules_Id = @pRuModules_Id  
 END  
         
END
