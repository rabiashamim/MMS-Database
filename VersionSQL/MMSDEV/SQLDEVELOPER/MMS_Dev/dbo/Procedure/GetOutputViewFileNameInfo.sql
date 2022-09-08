/****** Object:  Procedure [dbo].[GetOutputViewFileNameInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetOutputViewFileNameInfo]        
 @StatementProcessId DECIMAL(18,0)

AS
BEGIN


DROP TABLE IF EXISTS #temp;

SELECT  
	spd.SrProcessDef_Name AS ProcessName
	,ssd.SrStatementDef_Name AS StatementType
	,lam.LuAccountingMonth_MonthName AS MonthAndYear
INTO #temp
FROM 
	MtStatementProcess msp
JOIN SrProcessDef spd
ON 
	msp.SrProcessDef_ID = spd.SrProcessDef_ID
JOIN SrStatementDef ssd
	ON spd.SrStatementDef_ID = ssd.SrStatementDef_ID
JOIN LuAccountingMonth lam
	ON msp.LuAccountingMonth_Id_Current = lam.LuAccountingMonth_Id
WHERE 
	msp.MtStatementProcess_ID = @StatementProcessId

SELECT TOP 1 * FROM #temp t;

END
