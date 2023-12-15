/****** Object:  Procedure [dbo].[AddTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE AddTask
	@name VARCHAR(90),
	@description VARCHAR(90),
	@due_date DATE,
	@status VARCHAR(50)
AS
BEGIN
INSERT INTO MyTask (name, description, due_date, status)
VALUES (@name, @description, @due_date, @status);
END;
