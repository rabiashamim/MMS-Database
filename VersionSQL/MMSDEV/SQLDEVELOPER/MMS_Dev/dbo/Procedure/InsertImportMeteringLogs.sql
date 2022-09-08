/****** Object:  Procedure [dbo].[InsertImportMeteringLogs]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : ALI Imran
--Reviewer : <>
--CreatedDate : 14 March 2022
--Comments : LOGS for metering Import
--======================================================================
CREATE PROCEDURE [dbo].[InsertImportMeteringLogs]

@ImportMeteringLogs_JobType int NULL,
@ImportMeteringLogs_JobStatus [int] NULL,
@ImportMeteringLogs_DurationType [int] NULL,
@ImportMeteringLogs_Note varchar(200) NULL,
@ImportMeteringLogs_ExecutiontimeofAPI varchar(50) NULL,
@ImportMeteringLogs_EffectedRows int NULL

AS
BEGIN

INSERT INTO [dbo].[ImportMeteringLogs]
           ([ImportMeteringLogs_JobType]
           ,[ImportMeteringLogs_JobStatus]
           ,[ImportMeteringLogs_DurationType]
           ,[ImportMeteringLogs_Note]
           ,[ImportMeteringLogs_ExecutiontimeofAPI]
           ,[ImportMeteringLogs_EffectedRows]
           ,[ImportMeteringLogs_CreatedOn]
           ,[ImportMeteringLogs_IsDeleted]
           ,[ImportMeteringLogs_CreatedBy]
           )
     VALUES
           (
		    @ImportMeteringLogs_JobType 
		   ,@ImportMeteringLogs_JobStatus
	       ,@ImportMeteringLogs_DurationType
	       ,@ImportMeteringLogs_Note 
	       ,@ImportMeteringLogs_ExecutiontimeofAPI
	       ,@ImportMeteringLogs_EffectedRows
           ,DATEADD(HOUR,5, GETUTCDATE())
           ,0
           ,100
          )

END
