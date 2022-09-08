/****** Object:  View [dbo].[V_StatementProcesses]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 
/*AND (LuStatus_Code_Applicant <> 'REJ')*/
CREATE VIEW [dbo].[V_StatementProcesses]
AS

WITH StatementProcess_CTE
AS
(

SELECT SP.MtStatementProcess_ID,SP.SrProcessDef_ID,PD.SrProcessDef_Name,PD.SrStatementDef_ID,SP.LuAccountingMonth_Id_Current,
AM.LuAccountingMonth_Month,AM.LuAccountingMonth_Year,AM.LuStatus_Code
 FROM MtStatementProcess SP
INNER JOIN SrProcessDef PD ON SP.SrProcessDef_ID = PD.SrProcessDef_ID
INNER JOIN LuAccountingMonth AM ON SP.LuAccountingMonth_Id_Current=AM.LuAccountingMonth_Id 
WHERE SP.MtStatementProcess_IsDeleted=0 AND AM.LuAccountingMonth_IsDeleted=0
)

select distinct S1.MtStatementProcess_ID,S1.SrProcessDef_ID,S1.SrProcessDef_Name,S1.SrStatementDef_ID,
S1.LuAccountingMonth_Id_Current,S1.LuAccountingMonth_Month,S1.LuAccountingMonth_Year,S1.LuStatus_Code,S2.MtStatementProcess_ID as CurrentStatementProcess_ID from StatementProcess_CTE S1 JOIN
StatementProcess_CTE S2 ON S1.LuAccountingMonth_Id_Current=S2.LuAccountingMonth_Id_Current
AND S1.SrStatementDef_ID=S2.SrStatementDef_ID 
