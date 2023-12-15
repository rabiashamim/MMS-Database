/****** Object:  Procedure [dbo].[GetEmployees]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE GetEmployees
AS
BEGIN
	SELECT * FROM Employee WHERE IsDeleted = 0;
END
