/****** Object:  Table [dbo].[MtStatementProcessInput]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtStatementProcessInput](
	[MtStatementProcessInput_Id] [decimal](18, 0) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
	[SrProcessDef_ID] [int] NOT NULL,
	[RuProcessInputDef_ID] [int] NULL,
	[MtStatementProcessInput_Version] [int] NULL,
	[MtStatementProcessInput_CreatedBy] [decimal](18, 0) NULL,
	[MtStatementProcessInput_CreatedOn] [datetime] NULL,
	[MtStatementProcessInput_ModifiedBy] [decimal](18, 0) NULL,
	[MtStatementProcessInput_ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_StatementProcessInput] PRIMARY KEY CLUSTERED 
(
	[MtStatementProcessInput_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtStatementProcessInput]  WITH CHECK ADD  CONSTRAINT [FK_MtStatementProcessInput_ProcessInputDef] FOREIGN KEY([RuProcessInputDef_ID])
REFERENCES [dbo].[RuProcessInputDef] ([RuProcessInputDef_ID])
ALTER TABLE [dbo].[MtStatementProcessInput] CHECK CONSTRAINT [FK_MtStatementProcessInput_ProcessInputDef]
ALTER TABLE [dbo].[MtStatementProcessInput]  WITH CHECK ADD  CONSTRAINT [FK_MtStatementProcessInput_StatementProcess] FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE [dbo].[MtStatementProcessInput] CHECK CONSTRAINT [FK_MtStatementProcessInput_StatementProcess]
