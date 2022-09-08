/****** Object:  Table [dbo].[Mt_SystemLogs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Mt_SystemLogs](
	[Mt_SystemLogs_Id] [int] NOT NULL,
	[Mt_SystemLogs_ActionTime] [datetime] NOT NULL,
	[Mt_SystemLogs_ModuleType_Id] [int] NOT NULL,
	[Mt_SystemLogs_CrudOperation_Id] [int] NOT NULL,
	[Mt_SystemLogs_Message] [varchar](max) NULL,
	[Mt_SystemLogs_IPAddress] [varchar](max) NULL,
	[Mt_SystemLogs_DeviceType] [varchar](max) NULL,
	[Mt_SystemLogs_CreatedOn] [datetime] NULL,
	[Mt_SystemLogs_CreatedBy] [int] NULL,
	[Mt_SystemLogs_User] [int] NOT NULL,
	[Mt_SystemLogs_UserName] [varchar](max) NULL,
	[Mt_SystemLogs_PartyRegistrationID] [decimal](18, 0) NULL,
	[Mt_SystemLogs_PartyCategoryID] [decimal](18, 0) NULL,
	[Mt_SystemLogs_FeaturePK] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[Mt_SystemLogs_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
