/****** Object:  Table [dbo].[MtStatementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtStatementProcess](
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[SrProcessDef_ID] [int] NULL,
	[LuAccountingMonth_Id_Current] [int] NULL,
	[LuAccountingMonth_Id] [int] NULL,
	[MtStatementProcess_ExecutionStartDate] [datetime] NULL,
	[MtStatementProcess_ExecutionFinishDate] [datetime] NULL,
	[MtStatementProcess_Status] [nvarchar](50) NULL,
	[MtStatementProcess_ApprovalStatus] [nvarchar](50) NULL,
	[MtStatementProcess_CreatedBy] [decimal](18, 0) NULL,
	[MtStatementProcess_CreatedOn] [datetime] NULL,
	[MtStatementProcess_ModifiedBy] [decimal](18, 0) NULL,
	[MtStatementProcess_ModifiedOn] [datetime] NULL,
	[MtStatementProcess_IsDeleted] [bit] NULL,
	[MtStatementProcess_UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Statement] PRIMARY KEY CLUSTERED 
(
	[MtStatementProcess_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtStatementProcess] ADD  DEFAULT ((0)) FOR [MtStatementProcess_IsDeleted]
ALTER TABLE [dbo].[MtStatementProcess]  WITH CHECK ADD  CONSTRAINT [FK_StatementProcess_ProcessDef] FOREIGN KEY([SrProcessDef_ID])
REFERENCES [dbo].[SrProcessDef] ([SrProcessDef_ID])
ALTER TABLE [dbo].[MtStatementProcess] CHECK CONSTRAINT [FK_StatementProcess_ProcessDef]
ALTER TABLE [dbo].[MtStatementProcess]  WITH CHECK ADD  CONSTRAINT [FK_StatementProcess_SettIementPeriod2] FOREIGN KEY([LuAccountingMonth_Id_Current])
REFERENCES [dbo].[LuAccountingMonth] ([LuAccountingMonth_Id])
ALTER TABLE [dbo].[MtStatementProcess] CHECK CONSTRAINT [FK_StatementProcess_SettIementPeriod2]
ALTER TABLE [dbo].[MtStatementProcess]  WITH CHECK ADD  CONSTRAINT [FK_StatementProcess_SettIementPeriod3] FOREIGN KEY([LuAccountingMonth_Id])
REFERENCES [dbo].[LuAccountingMonth] ([LuAccountingMonth_Id])
ALTER TABLE [dbo].[MtStatementProcess] CHECK CONSTRAINT [FK_StatementProcess_SettIementPeriod3]
