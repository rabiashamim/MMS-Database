/****** Object:  Procedure [dbo].[GetMyTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   PROCEDURE GetMyTask
    @topTasks INT
AS
BEGIN
    SELECT TOP (@topTasks) *
    FROM mytask
	WHERE IsDeleted=0;
END;
