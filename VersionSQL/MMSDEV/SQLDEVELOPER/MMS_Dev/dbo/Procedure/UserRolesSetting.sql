/****** Object:  Procedure [dbo].[UserRolesSetting]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 1 March 2022
--Comments : FOR Roles Assinging a
-- UserRolesSetting 1,'1'
--======================================================================
CREATE PROCEDURE [dbo].[UserRolesSetting]

@pUserId INT,
@pRoleIds varchar(100)
AS
BEGIN

/**********************************************************************************************
Declare variables
**********************************************************************************************/
DECLARE @vUserGUID varchar(100)

/**********************************************************************************************
Get user GUID 
**********************************************************************************************/


SELECT @vUserGUID=Id FROM AspNetUsers WHERE UserId=@pUserId

/**********************************************************************************************
Get User Roles which assign to user
**********************************************************************************************/
	SELECT 
		* 
	INTO
		#temp
	FROM 
		AspNetRoles 
	WHERE 
		RoleId in (Select Value from string_split(@pRoleIds,','))

/**********************************************************************************************
Delete user roles which are previously assing to them
**********************************************************************************************/

DELETE
FROM 
	AspNetUserRoles 
WHERE 
	UserId=@vUserGUID
	AND 
	RoleId NOT IN (SELECT Id FROM #temp)

/**********************************************************************************************
Insert new roles to the user
**********************************************************************************************/
INSERT INTO AspNetUserRoles
SELECT @vUserGUID, Id FROM #temp
WHERE Id NOT IN
(SELECT 
	RoleId
FROM 
	AspNetUserRoles 
WHERE 
	UserId=@vUserGUID)



END
