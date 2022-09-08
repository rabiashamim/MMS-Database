/****** Object:  Table [dbo].[ImportMeteringLogs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ImportMeteringLogs](
	[ImportMeteringLogs_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[ImportMeteringLogs_JobType] [int] NULL,
	[ImportMeteringLogs_JobStatus] [int] NULL,
	[ImportMeteringLogs_DurationType] [int] NULL,
	[ImportMeteringLogs_Note] [varchar](200) NULL,
	[ImportMeteringLogs_ExecutiontimeofAPI] [varchar](50) NULL,
	[ImportMeteringLogs_EffectedRows] [int] NULL,
	[ImportMeteringLogs_CreatedOn] [datetime] NOT NULL,
	[ImportMeteringLogs_ModifiedOn] [datetime] NULL,
	[ImportMeteringLogs_IsDeleted] [bit] NULL,
	[ImportMeteringLogs_CreatedBy] [decimal](18, 0) NOT NULL,
	[ImportMeteringLogs_ModifiedBy] [decimal](18, 0) NULL,
	[ImportMeteringLogs_Percentage] [decimal](4, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[ImportMeteringLogs_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'-- 1 MeteringMaster, 2 CDPMaster, 3 BVMHourly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ImportMeteringLogs', @level2type=N'COLUMN',@level2name=N'ImportMeteringLogs_JobType'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N' -- 1 Success 2 Failer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ImportMeteringLogs', @level2type=N'COLUMN',@level2name=N'ImportMeteringLogs_JobStatus'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N' -- 1 Daily 2 Weekly 3 BiWeekly 4 TriWeekly 5 Monthly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ImportMeteringLogs', @level2type=N'COLUMN',@level2name=N'ImportMeteringLogs_DurationType'
