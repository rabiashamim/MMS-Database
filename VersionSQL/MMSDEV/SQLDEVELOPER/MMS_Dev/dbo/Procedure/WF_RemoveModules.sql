/****** Object:  Procedure [dbo].[WF_RemoveModules]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE      PROCEDURE dbo.WF_RemoveModules        
		   @pRuModule_Id int=0
           ,@pUserId      DECIMAL(18,0)=0       
AS                   
BEGIN    
update RuModules set RuModules_IsDeleted=1 where RuModules_Id=@pRuModule_Id
END
/**************************************************/
