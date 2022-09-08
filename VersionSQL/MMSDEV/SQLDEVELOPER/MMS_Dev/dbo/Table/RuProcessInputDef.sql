/****** Object:  Table [dbo].[RuProcessInputDef]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuProcessInputDef](
	[RuProcessInputDef_ID] [int] NOT NULL,
	[RuProcessInputDef_Name] [nvarchar](50) NULL,
	[RuProcessInputDef_SourceTable] [nvarchar](50) NULL,
	[SrProcessDef_ID] [int] NULL,
	[RuProcessInputDef_PredecessorID] [decimal](18, 0) NULL,
	[RuProcessInputDef_CreatedBy] [decimal](18, 0) NULL,
	[RuProcessInputDef_CreatedOn] [datetime] NULL,
	[RuProcessInputDef_ModifiedBy] [decimal](18, 0) NULL,
	[RuProcessInputDef_ModifiedOn] [datetime] NULL,
	[LuSOFileTemplate_Id] [decimal](18, 0) NULL,
	[RuProcessInputDef_Description] [varchar](500) NULL,
 CONSTRAINT [PK_ProcessInputDef] PRIMARY KEY CLUSTERED 
(
	[RuProcessInputDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[RuProcessInputDef] ADD  DEFAULT (NULL) FOR [LuSOFileTemplate_Id]
ALTER TABLE [dbo].[RuProcessInputDef] ADD  DEFAULT (NULL) FOR [RuProcessInputDef_Description]
ALTER TABLE [dbo].[RuProcessInputDef]  WITH CHECK ADD  CONSTRAINT [FK_ProcessInputDef_ProcessDef] FOREIGN KEY([SrProcessDef_ID])
REFERENCES [dbo].[SrProcessDef] ([SrProcessDef_ID])
ALTER TABLE [dbo].[RuProcessInputDef] CHECK CONSTRAINT [FK_ProcessInputDef_ProcessDef]
