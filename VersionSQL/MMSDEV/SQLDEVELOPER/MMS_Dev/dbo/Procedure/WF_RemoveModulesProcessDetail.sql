/****** Object:  Procedure [dbo].[WF_RemoveModulesProcessDetail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE      PROCEDURE dbo.WF_RemoveModulesProcessDetail        
		   @pRuModulesProcessDetails_Id int=0
           ,@pUserId      DECIMAL(18,0)=0       
AS                   
BEGIN    
update RuModulesProcessDetails set RuModulesProcessDetails_IsDeleted=1 where RuModulesProcessDetails_Id=@pRuModulesProcessDetails_Id
END
/**************************************************/
