/****** Object:  Procedure [dbo].[WF_GetSubModulesTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:  <Aymen Khalid>        
-- Create date: <22-02-2022>        
-- Description: <Returns the Template ID period typeSub Modules of given modules>        
-- =============================================      
CREATE PROCEDURE dbo.WF_GetSubModulesTemplate    
@pRuModulesProcess_Name as varchar(128)  
    
AS BEGIN    
    
SELECT  
	RuModulesProcess_ProcessTemplateId 
FROM 
	RuModulesProcess
WHERE 
	RuModulesProcess_Name = @pRuModulesProcess_Name
	AND 
	ISNULL(RuModulesProcess_IsDeleted,0) = 0
   
END
