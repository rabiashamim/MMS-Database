/****** Object:  Procedure [dbo].[WF_GetModulesProcesses]    Committed by VersionSQL https://www.versionsql.com ******/

/***************************************
		Sadaf Malik
		13-Feb-2023
*****************************************/
CREATE     PROCEDURE dbo.WF_GetModulesProcesses
@pRuModules_Id as int=0

AS BEGIN

SELECT
	RM.RuModules_Id
   ,RM.RuModules_Name
	, RMP.RuModulesProcess_Id
	, RMP.RuModulesProcess_Name
	,RMP.RuModulesProcess_LinkedObject
	,RMP.RuModulesProcess_ProcessTemplateId
FROM RuModules RM
INNER JOIN  RuModulesProcess RMP on RMP.RuModules_Id=RM.RuModules_Id
where ISNULL(RuModules_IsDeleted,0)=0
AND ISNULL(RMP.RuModulesProcess_IsDeleted,0)=0
AND (
@pRuModules_Id=0 or RMP.RuModules_Id=@pRuModules_Id
)
END
