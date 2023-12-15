/****** Object:  Table [dbo].[RuStepDef]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuStepDef(
	[RuStepDef_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuStepDef_Name] [nvarchar](max) NULL,
	[RuStepDef_StepType] [nvarchar](50) NULL,
	[RuStepDef_ActionType] [nvarchar](50) NULL,
	[SrProcessDef_ID] [int] NULL,
	[RuStepDef_RegionName] [nvarchar](50) NULL,
	[RuStepDef_SequenceNo] [decimal](18, 0) NULL,
	[RuStepDef_SourceTable] [nvarchar](100) NULL,
	[RuStepDef_WhereClause] [nvarchar](1000) NULL,
	[RuStepDef_HavingClause] [nvarchar](500) NULL,
	[RuStepDef_OrderByClause] [nvarchar](500) NULL,
	[RuStepDef_GroupByClause] [nvarchar](500) NULL,
	[RuStepDef_EffectiveDateFrom] [date] NULL,
	[RuStepDef_EffectiveDateTo] [date] NULL,
	[RuStepDef_CreatedBy] [decimal](18, 0) NULL,
	[RuStepDef_CreatedOn] [datetime] NULL,
	[RuStepDef_ModifiedBy] [decimal](18, 0) NULL,
	[RuStepDef_ModifiedOn] [datetime] NULL,
	[RuStepDef_BMEStepNo] [decimal](18, 4) NULL,
	[RuStepDef_IsDeleted] [bit] NULL,
 CONSTRAINT [PK_RuStepDef] PRIMARY KEY CLUSTERED 
(
	[RuStepDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.RuStepDef ADD  CONSTRAINT [DF__RuStepDef__RuSte__5DF5D7ED]  DEFAULT ((0)) FOR [RuStepDef_IsDeleted]
ALTER TABLE dbo.RuStepDef  WITH CHECK ADD  CONSTRAINT [FK_StepDef_ProcessDef] FOREIGN KEY([SrProcessDef_ID])
REFERENCES [dbo].[SrProcessDef] ([SrProcessDef_ID])
ALTER TABLE dbo.RuStepDef CHECK CONSTRAINT [FK_StepDef_ProcessDef]
