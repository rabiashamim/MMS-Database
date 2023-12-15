/****** Object:  Procedure [dbo].[WF_GetModules]    Committed by VersionSQL https://www.versionsql.com ******/

/***************************************
		Sadaf Malik
		13-Feb-2023
*****************************************/
CREATE   PROCEDURE dbo.WF_GetModules
@pRuModules_Id as int=0

AS BEGIN

SELECT RuModules_Id, RuModules_Name, RuModules_IsActive FROM RuModules where ISNULL(RuModules_IsDeleted,0)=0
AND (
@pRuModules_Id=0 or RuModules_Id=@pRuModules_Id
)
END
