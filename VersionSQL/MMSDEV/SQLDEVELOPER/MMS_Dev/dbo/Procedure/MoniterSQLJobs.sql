/****** Object:  Procedure [dbo].[MoniterSQLJobs]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 15 March 2022
--Comments : moniter sql jobs
--======================================================================

CREATE PROCEDURE [dbo].[MoniterSQLJobs]
AS
BEGIN

SELECT 
 TOP 100
 ImportMeteringLogs_Id
 ,
 CASE 
	WHEN ImportMeteringLogs_JobType=1 then 'Meter Master'
	WHEN ImportMeteringLogs_JobType=2 then 'CDP Master'
	WHEN ImportMeteringLogs_JobType=3 then 'BVM Hourly'
	else '-'
 END as JobType

,CASE 
	WHEN ImportMeteringLogs_JobStatus=1 and ImportMeteringLogs_ExecutiontimeofAPI <> 0 and ImportMeteringLogs_EffectedRows <> 0 then 'Pass'
	else 'Fail'
 END AS [status]
,CASE WHEN ImportMeteringLogs_DurationType=1 then 'Daily'
	WHEN ImportMeteringLogs_DurationType=2 then 'Weekly'
	WHEN ImportMeteringLogs_DurationType=3 then 'Biweekly'
	WHEN ImportMeteringLogs_DurationType=4 then 'Triweekly'
	WHEN ImportMeteringLogs_DurationType=5 then 'Monthly'
	WHEN ImportMeteringLogs_DurationType=6 then 'CDP Data Import'
	WHEN ImportMeteringLogs_DurationType=7 then 'Retry'
	WHEN ImportMeteringLogs_DurationType=8 then 'TetraWeekly'
	WHEN ImportMeteringLogs_DurationType=9 then 'Recall API'
	WHEN ImportMeteringLogs_DurationType=10 then 'SQL Job Monitor Date Range'
	else '-'
 END AS DurationType

	
		,ImportMeteringLogs_Note	
		,ImportMeteringLogs_ExecutiontimeofAPI
		,ImportMeteringLogs_Percentage
		,ImportMeteringLogs_EffectedRows	
		,ImportMeteringLogs_CreatedOn
 FROM 
		ImportMeteringLogs
 Where ISNULL(ImportMeteringLogs_IsDeleted,0)=0
 ORDER BY 
		ImportMeteringLogs_Id desc

 END
