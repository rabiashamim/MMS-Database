/****** Object:  Procedure [dbo].[DeleteTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE DeleteTask 
	@task_id INT
AS 
BEGIN
UPDATE MyTask
SET IsDeleted = 1 
WHERE task_id = @task_id;
END;
