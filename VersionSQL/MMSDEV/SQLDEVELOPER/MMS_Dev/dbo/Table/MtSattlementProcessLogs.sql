/****** Object:  Table [dbo].[MtSattlementProcessLogs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtSattlementProcessLogs](
	[MtSattlementProcessLog_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [int] NULL,
	[MtSattlementProcessLog_Message] [nvarchar](max) NULL,
	[MtSattlementProcessLog_CreatedBy] [int] NULL,
	[MtSattlementProcessLog_CreatedOn] [datetime] NULL,
	[MtSattlementProcessLog_ModifiedBy] [int] NULL,
	[MtSattlementProcessLog__ModifiedOn] [datetime] NULL,
	[MtSattlementProcessLog_ErrorLevel] [varchar](max) NULL,
 CONSTRAINT [PK_MtSattlementProcessLogs] PRIMARY KEY CLUSTERED 
(
	[MtSattlementProcessLog_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
