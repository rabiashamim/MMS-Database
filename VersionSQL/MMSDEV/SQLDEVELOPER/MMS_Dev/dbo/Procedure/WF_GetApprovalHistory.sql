/****** Object:  Procedure [dbo].[WF_GetApprovalHistory]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WF_GetApprovalHistory 3,2,'886',1                    
CREATE PROCEDURE dbo.WF_GetApprovalHistory @RuModule_id INT,
@Process_Template_Id INT,
@MtWFHistory_Process_id DECIMAL(18, 0),
@user_id DECIMAL(18, 0)
AS
	DECLARE @RuWorkFlowHeader_id INT
		   ,@RuModulesProcess_Id INT
	SELECT
		@RuModulesProcess_Id = RuModulesProcess_Id
	FROM RuModulesProcess
	WHERE RuModules_Id = @RuModule_id
	AND RuModulesProcess_ProcessTemplateId = @Process_Template_Id
	SELECT
		@RuWorkFlowHeader_id = RuWorkFlowHeader_id
	FROM RuWorkFlow_header
	WHERE RuModulesProcess_Id = @RuModulesProcess_Id

	CREATE TABLE #WF_headers (
		wf_header_id INT
	)
	/*Party Registration*/
	IF ISNULL(@RuModule_id, 0) = 1
	BEGIN
		INSERT INTO #WF_headers
			SELECT
				RuWorkFlowHeader_id
			FROM RuWorkFlow_header
			WHERE RuModulesProcess_Id IN (SELECT
					RuModulesProcess_Id
				FROM RuModulesProcess
				WHERE RuModules_Id = @RuModule_id)
	--BETWEEN 13 AND 18                
	END
	/*Contract Registration*/
	ELSE
	IF ISNULL(@RuModule_id, 0) = 12
	BEGIN
		INSERT INTO #WF_headers
			SELECT
				RuWorkFlowHeader_id
			FROM RuWorkFlow_header
			WHERE RuModulesProcess_Id IN (SELECT
					RuModulesProcess_Id
				FROM RuModulesProcess
				WHERE RuModules_Id = @RuModule_id)
	--where RuModulesProcess_Id BETWEEN 21 AND 26                
	END
	ELSE
	BEGIN
		INSERT INTO #WF_headers
			SELECT
				@RuWorkFlowHeader_id
	END


	SELECT
		RuWorkFlowHeader_id
	   ,MtWFHistory_Process_id
	   ,MtWFHistory_Process_name
	   ,MtWFHistory_LevelID
	   ,MtWFHistory_ActionDate
	   ,LuStatus_Name--MtWFHistory_Action                                            
	   ,MtWFHistory_FromResource
	   ,u.FirstName + ' ' + u.LastName + ' (' + Lu_Designation_Name + ' - ' + Lu_Department_Name + ')' FromResource_name
	   ,MtWFHistory_ToResource
	   ,u.FirstName + ' ' + u.LastName ToResource_name
	   ,MtWFHistory_comments
	   ,MtWFHistory_SequenceID MtWFHistory_SequenceID_old
	   ,MtWFHistory_id INTO #resources
	FROM MtWFHistory w
	INNER JOIN [LuStatus] s
		ON w.MtWFHistory_Action = s.LuStatus_Code
	INNER JOIN AspNetUsers u
		ON w.MtWFHistory_FromResource = u.UserId
	INNER JOIN Lu_Department d
		ON u.Lu_Department_Id = d.Lu_Department_Id
	INNER JOIN Lu_Designation de
		ON de.Lu_Designation_Id = u.Lu_Designation_Id
	WHERE RuWorkFlowHeader_id IN (SELECT
			wf_header_id
		FROM #WF_headers)
	AND MtWFHistory_Process_id = @MtWFHistory_Process_id

	UPDATE w
	SET ToResource_name = u.FirstName + ' ' + u.LastName + ' (' + Lu_Designation_Name + ' - ' + Lu_Department_Name + ')'
	FROM #resources w
	INNER JOIN AspNetUsers u
		ON w.MtWFHistory_ToResource = u.UserId
	INNER JOIN Lu_Department d
		ON u.Lu_Department_Id = d.Lu_Department_Id
	INNER JOIN Lu_Designation de
		ON de.Lu_Designation_Id = u.Lu_Designation_Id


	UPDATE w
	SET ToResource_name = ''
	FROM #resources w
	WHERE w.MtWFHistory_ToResource IS NULL

	--select * from #resources order by MtWFHistory_ActionDate,MtWFHistory_SequenceID                 


	SELECT
		ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY MtWFHistory_id DESC) MtWFHistory_SequenceID
	   ,* INTO #result
	FROM #resources
	ORDER BY MtWFHistory_id




	ALTER TABLE #result ADD wf_process_name VARCHAR(250)

	UPDATE w
	SET wf_process_name = rmp.RuModulesProcess_Name
	FROM #result w
	INNER JOIN RuWorkFlow_header rwfh
		ON w.RuWorkFlowHeader_id = rwfh.RuWorkFlowHeader_id
	INNER JOIN RuModulesProcess rmp
		ON rwfh.RuModulesProcess_Id = rmp.RuModulesProcess_Id


	SELECT
		*
	FROM #result
	ORDER BY MtWFHistory_SequenceID


	DROP TABLE #WF_headers
	DROP TABLE #resources
