/****** Object:  Procedure [dbo].[AddModules]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 1 March 2022
--Comments : ADD Modules
--======================================================================
-- AddModules @pModuleName= 'BME4' ,@Modules_Id=0,@Module_IsActive=1
CREATE PROCEDURE [dbo].[AddModules]
@pModuleName varchar(100),
@Modules_Id INT,
@Module_IsActive BIT

AS
BEGIN

	IF(@Modules_Id>0)
	BEGIN

	IF EXISTS(SELECT 1 FROM RuModules WHERE RuModules_Id<>@Modules_Id AND  RuModules_Name=@pModuleName AND ISNULL(RuModules_IsDeleted,0)=0)
	BEGIN
		Select '0'
		return;
	END
         UPDATE 
		   	RuModules 
         SET 
       		RuModules_Name = @pModuleName ,
			RuModules_ModifiedOn = GETDATE(),
			RuModules_IsActive=@Module_IsActive,
			RuModules_ModifiedBy=100
        WHERE 
       		RuModules_Id=@Modules_Id
       RETURN;
	END

IF EXISTS(SELECT 1 FROM RuModules WHERE RuModules_Name=@pModuleName AND ISNULL(RuModules_IsDeleted,0)=0)
BEGIN
	Select '0'
	return;
END




INSERT INTO RuModules VALUES
(@pModuleName,@Module_IsActive,100,GETUTCDATE(),null,null,0, 1)

DECLARE @vModuleId INT;
SELECT @vModuleId= RuModules_Id FROM RuModules WHERE RuModules_Name=@pModuleName;

INSERT INTO [dbo].[AspNetRoles] VALUES
(NEWID(),@pModuleName+'_View',@vModuleId,1)

INSERT INTO [dbo].[AspNetRoles] VALUES
(NEWID(),@pModuleName+'_Editor',@vModuleId,2)

--INSERT INTO [dbo].[AspNetRoles] VALUES
--(NEWID(),@pModuleName+'_Reports',@vModuleId,3)


INSERT INTO [dbo].[AspNetRoles] VALUES
(NEWID(),@pModuleName+'_Approval',@vModuleId,4)


END
