/****** Object:  Procedure [dbo].[WF_RemoveModulesProcesses]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE      PROCEDURE dbo.WF_RemoveModulesProcesses        
		   @pRuModulesProcess_Id int=0
           ,@pUserId      DECIMAL(18,0)=0       
AS                   
BEGIN    
update RuModulesProcess set RuModulesProcess_IsDeleted=1 where RuModulesProcess_Id=@pRuModulesProcess_Id
END
/**************************************************/
