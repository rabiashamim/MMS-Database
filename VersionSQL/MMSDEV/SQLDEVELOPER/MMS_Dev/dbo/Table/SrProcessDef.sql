/****** Object:  Table [dbo].[SrProcessDef]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.SrProcessDef(
	[SrProcessDef_ID] [int] NOT NULL,
	[SrProcessDef_Name] [nvarchar](50) NULL,
	[SrStatementDef_ID] [int] NULL,
	[SrProcessDef_PredecessorID] [decimal](18, 0) NULL,
	[SrProcessDef_CreatedBy] [decimal](18, 0) NULL,
	[SrProcessDef_CreatedOn] [datetime] NULL,
	[SrProcessDef_ModifiedBy] [decimal](18, 0) NULL,
	[SrProcessDef_ModifiedOn] [datetime] NULL,
	[SrProcessDef_PreviousProcessPredecessorID] [int] NULL,
	[SrProcessDef_PeriodType] [int] NOT NULL,
 CONSTRAINT [PK_ProcessDef] PRIMARY KEY CLUSTERED 
(
	[SrProcessDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.SrProcessDef ADD  DEFAULT ((0)) FOR [SrProcessDef_PeriodType]
ALTER TABLE dbo.SrProcessDef  WITH CHECK ADD  CONSTRAINT [FK_ProcessDef_StatementDef] FOREIGN KEY([SrStatementDef_ID])
REFERENCES [dbo].[SrStatementDef] ([SrStatementDef_ID])
ALTER TABLE dbo.SrProcessDef CHECK CONSTRAINT [FK_ProcessDef_StatementDef]
