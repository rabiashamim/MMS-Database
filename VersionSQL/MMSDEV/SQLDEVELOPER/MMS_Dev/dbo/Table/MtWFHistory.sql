/****** Object:  Table [dbo].[MtWFHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtWFHistory](
	[MtWFHistory_id] [int] IDENTITY(1,1) NOT NULL,
	[RuWorkFlowHeader_id] [int] NOT NULL,
	[MtWFHistory_Process_id] [decimal](18, 0) NOT NULL,
	[MtWFHistory_Process_name] [nvarchar](256) NULL,
	[MtWFHistory_LevelID] [int] NOT NULL,
	[MtWFHistory_SequenceID] [int] NOT NULL,
	[MtWFHistory_ActionDate] [datetime] NULL,
	[MtWFHistory_Action] [char](4) NULL,
	[MtWFHistory_FromResource] [decimal](18, 0) NULL,
	[MtWFHistory_ToResource] [decimal](18, 0) NULL,
	[MtWFHistory_comments] [nvarchar](256) NULL,
	[MtWFHistory_ProcessFinalApproval] [int] NULL,
	[MtWFHistory_ProcessRejected] [int] NULL,
	[MtWFHistory_NotificationSubject] [nvarchar](256) NULL,
	[MtWFHistory_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtWFHistory_CreatedOn] [datetime] NOT NULL,
	[MtWFHistory_ModifiedBy] [decimal](18, 0) NULL,
	[MtWFHistory_ModifiedOn] [datetime] NULL,
	[is_initiator] [int] NULL,
	[notify_flag] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuWorkFlowHeader_id] ASC,
	[MtWFHistory_Process_id] ASC,
	[MtWFHistory_LevelID] ASC,
	[MtWFHistory_SequenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
