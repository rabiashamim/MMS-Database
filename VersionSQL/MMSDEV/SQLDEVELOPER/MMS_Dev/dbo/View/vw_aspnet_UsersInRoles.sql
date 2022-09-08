/****** Object:  View [dbo].[vw_aspnet_UsersInRoles]    Committed by VersionSQL https://www.versionsql.com ******/

  CREATE VIEW [dbo].[vw_aspnet_UsersInRoles]
  AS SELECT [dbo].[aspnet_UsersInRoles].[UserId], [dbo].[aspnet_UsersInRoles].[RoleId]
  FROM [dbo].[aspnet_UsersInRoles]
  
