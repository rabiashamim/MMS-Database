/****** Object:  Table [dbo].[RuNotificationSetup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuNotificationSetup](
	[RuNotificationSetup_ID] [int] IDENTITY(1,1) NOT NULL,
	[RuWorkFlowHeader_id] [int] NULL,
	[RuNotificationSetup_CategoryKey] [varchar](256) NOT NULL,
	[RuNotificationSetup_CategoryDescription] [varchar](256) NULL,
	[RuNotificationSetup_Status] [int] NULL,
	[RuNotificationSetup_FromAddress] [varchar](256) NULL,
	[RuNotificationSetup_ToAddress] [varchar](256) NULL,
	[RuNotificationSetup_CcAddress] [varchar](256) NULL,
	[RuNotificationSetup_EmailSubject] [varchar](max) NULL,
	[RuNotificationSetup_EmailBody] [varchar](max) NULL,
	[RuNotificationSetup_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuNotificationSetup_CreatedOn] [datetime] NOT NULL,
	[RuNotificationSetup_ModifiedBy] [decimal](18, 0) NULL,
	[RuNotificationSetup_ModifiedOn] [datetime] NULL,
	[RuModules_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RuModules_id] ASC,
	[RuNotificationSetup_CategoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
