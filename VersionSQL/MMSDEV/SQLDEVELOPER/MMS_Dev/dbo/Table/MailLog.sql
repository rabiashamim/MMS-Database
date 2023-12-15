/****** Object:  Table [dbo].[MailLog]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MailLog(
	[MailID] [int] NULL,
	[WorkflowHeaderID] [int] NULL,
	[ToResource] [varchar](255) NULL,
	[MailSubject] [varchar](max) NULL,
	[SentDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
