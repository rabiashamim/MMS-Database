/****** Object:  Procedure [dbo].[GetStatementProcessInputs]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================  
--Author  : Sadaf | Ali  
--Reviewer : <>  
--CreatedDate :10 May 2022  
--======================================================================  

--select * from MtStatementProcess order by 1 desc
--[dbo].[GetStatementProcessInputs] 200
CREATE PROCEDURE [dbo].[GetStatementProcessInputs]
 @pStatementProcessId DECIMAL(18, 0) 

AS
BEGIN
	---------------------------Get Process Id
	/***********************************************************************  
   
 ***********************************************************************/
	DECLARE @SrProcessDef_Id AS INT
	DECLARE @LuAccountingMonth_Id AS INT

	/***********************************************************************  
   
 ***********************************************************************/
	SELECT
		@SrProcessDef_Id = SrProcessDef_ID
	   ,@LuAccountingMonth_Id = LuAccountingMonth_Id_Current
	FROM MtStatementProcess
	WHERE MtStatementProcess_ID = @pStatementProcessId;

	/***********************************************************************  
   
 ***********************************************************************/
	SELECT
		SrProcessDef_ID INTO #tempProcessesList
	FROM SrProcessDef
	WHERE SrStatementDef_ID = (SELECT
			SrStatementDef_ID
		FROM SrProcessDef
		WHERE SrProcessDef_ID = @SrProcessDef_Id)
	AND SrProcessDef_ID < @SrProcessDef_Id

	
	/***********************************************************************  
   
 ***********************************************************************/
	if(@SrProcessDef_Id<>12)
	BEGIN
	SELECT
		MtStatementProcess_ID
	   ,SrProcessDef_ID
	   ,LuAccountingMonth_Id
	   ,LuAccountingMonth_Id_Current INTO #temp
	FROM MtStatementProcess
	WHERE LuAccountingMonth_Id_Current = @LuAccountingMonth_Id
	AND SrProcessDef_ID IN (SELECT
			SrProcessDef_ID
		FROM #tempProcessesList)
	AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

union
		SELECT
		MtStatementProcess_ID
	   ,SrProcessDef_ID
	   ,LuAccountingMonth_Id  
	   , LuAccountingMonth_Id_Current  --INTO #temp
	FROM MtStatementProcess
	WHERE LuAccountingMonth_Id = @LuAccountingMonth_Id
	AND SrProcessDef_ID IN (7,8)--(12)  -- BME AND ASC ESS
	AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0
	/***********************************************************************  
	   
	 ***********************************************************************/
	SELECT
		ROW_NUMBER() OVER (ORDER BY t.MtStatementProcess_ID) AS Id
	   ,t.MtStatementProcess_ID
	   ,t.SrProcessDef_ID
	   ,CASE WHEN t.SrProcessDef_ID =12 --(12 means aggreagated ESS)
	   then t.LuAccountingMonth_Id
	   else t.LuAccountingMonth_Id_Current
	   END AS LuAccountingMonth_Id_Current
	   ,MonthName = (SELECT
				LuAccountingMonth_MonthName
			FROM LuAccountingMonth
			WHERE LuAccountingMonth_Id = t.LuAccountingMonth_Id_Current)
	   ,ProcessName = (SELECT
				CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
			FROM SrStatementDef SSD
			INNER JOIN SrProcessDef SPD
				ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
			WHERE SPD.SrProcessDef_Id = t.SrProcessDef_ID)
	FROM #temp t
	ORDER BY t.SrProcessDef_Id

	END
--********************************************************************************
ELSE
	BEGIN
	SELECT
		MtStatementProcess_ID
	   ,SrProcessDef_ID
	   ,LuAccountingMonth_Id
	   ,LuAccountingMonth_Id_Current INTO #tempESS
	FROM MtStatementProcess
	WHERE LuAccountingMonth_Id_Current = @LuAccountingMonth_Id
	AND SrProcessDef_ID IN (SELECT
			SrProcessDef_ID
		FROM #tempProcessesList)
	AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

	SELECT
		ROW_NUMBER() OVER (ORDER BY t.MtStatementProcess_ID) AS Id
	   ,t.MtStatementProcess_ID
	   ,t.SrProcessDef_ID
	   ,CASE WHEN t.SrProcessDef_ID =12 --(12 means aggreagated ESS)
	   then t.LuAccountingMonth_Id
	   else t.LuAccountingMonth_Id_Current
	   END AS LuAccountingMonth_Id_Current
	   ,MonthName = (SELECT
				LuAccountingMonth_MonthName
			FROM LuAccountingMonth
			WHERE LuAccountingMonth_Id = t.LuAccountingMonth_Id_Current)
	   ,ProcessName = (SELECT
				CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
			FROM SrStatementDef SSD
			INNER JOIN SrProcessDef SPD
				ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
			WHERE SPD.SrProcessDef_Id = t.SrProcessDef_ID)
	FROM #tempESS t
	ORDER BY  t.LuAccountingMonth_Id_Current DESC--, t.SrProcessDef_Id

	END
	--***********************	ELSE ends here
END
