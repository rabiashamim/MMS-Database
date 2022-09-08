/****** Object:  Procedure [dbo].[UserLogin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[UserLogin]
@pUserName VARCHAR(50)
,@pPassword VARCHAR(50)
AS
BEGIN
	SELECT * 
	FROM 
		dbo.Users 
	WHERE 
	Users_UserName=@pUserName 
	and Users_Password=@pPassword
END
