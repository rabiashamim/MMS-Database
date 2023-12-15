/****** Object:  Procedure [dbo].[UpdateTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   PROCEDURE UpdateTask
	@task_id INT,
	@name VARCHAR(90),
	@description VARCHAR(90),
	@status VARCHAR(50)
AS
BEGIN 
UPDATE MyTask
SET name = @name, description = @description, status = @status
WHERE task_id = @task_id;
END;
