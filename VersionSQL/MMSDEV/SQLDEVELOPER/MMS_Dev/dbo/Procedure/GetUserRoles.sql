/****** Object:  Procedure [dbo].[GetUserRoles]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 1 March 2022
--Comments : FOR Roles Assinging a
-- GetUserRoles 1
--======================================================================
CREATE PROCEDURE [dbo].[GetUserRoles]
@pUserId INT,
@pIsAdmin BIT

AS
BEGIN


/**********************************************************************************************
Declare variables
**********************************************************************************************/

DECLARE @vUserGUID varchar(100)
SELECT @vUserGUID=Id FROM AspNetUsers WHERE UserId=@pUserId

/**********************************************************************************************

**********************************************************************************************/
Select 
	 R.RuModules_Id,
	
	Cast(R.RoleMasterId as varchar(100))
	+',' + Case When UR.UserId is null then  '0' else '1' end
	+','+ Cast(R.RoleId AS VARCHAR(100))
	 as Info
INTO #temp

FROM 
	AspNetRoles R
 JOIN RuModules M ON M.RuModules_Id= R.RuModules_Id 
LEFT JOIN  AspNetUserRoles  UR  ON UR.RoleId=R.Id AND UserId=@vUserGUID
WHERE 
 ISNULL(M.RuModules_IsDeleted,0)=0
/**********************************************************************************************

**********************************************************************************************/
SELECT x.RuModules_Id as ModuleId,[R1],[R2],[R3],[R4]  into #temp2 FROM
(
select RuModules_Id,info,case 
when LEFT(info,1)=1 then 'R1'
when LEFT(info,1)=2 then 'R2'
when LEFT(info,1)=3 then 'R3'
when LEFT(info,1)=4 then 'R4' ELSE '' END as Mtype from #temp
)Tbl
Pivot
(
  MAX(info) FOR Mtype IN ([R1],[R2],[R3],[R4])
)x

	SELECT 
		RM.RuModules_Name AS Names
		,t.*
	FROM 
		#temp2 t
	JOIN RuModules RM ON RM.RuModules_Id=t.ModuleId 
	where 
	(@pIsAdmin=1 and RM.RuModules_IsVisible = @pIsAdmin)
	or (@pIsAdmin=0)

END
