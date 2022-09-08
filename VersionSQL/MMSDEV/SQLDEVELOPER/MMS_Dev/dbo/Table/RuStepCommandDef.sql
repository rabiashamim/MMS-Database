/****** Object:  Table [dbo].[RuStepCommandDef]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuStepCommandDef](
	[RuStepCommonadDef_ID] [decimal](18, 0) NOT NULL,
	[RuStepDef_ID] [decimal](18, 0) NOT NULL,
	[RuStepCommonadDef_Name] [nvarchar](50) NULL,
	[RuStepCommonadDef_StepType] [nvarchar](50) NULL,
	[RuStepCommonadDef_ActionType] [nvarchar](50) NULL,
	[SrProcessDef_ID] [int] NULL,
	[RuStepCommonadDef_SequenceNo] [decimal](18, 0) NULL,
	[RuStepCommonadDef_SourceTable] [nvarchar](100) NULL,
	[RuStepCommonadDef_TargetTable] [nvarchar](100) NULL,
	[RuStepCommonadDef_WhereClause] [nvarchar](1000) NULL,
	[RuStepCommonadDef_HavingClause] [nvarchar](500) NULL,
	[RuStepCommonadDef_OrderByClause] [nvarchar](500) NULL,
	[RuStepCommonadDef_GroupByClause] [nvarchar](500) NULL,
	[RuStepCommonadDef_EffectiveDateFrom] [date] NULL,
	[RuStepCommonadDef_EffectiveDateTo] [date] NULL,
	[RuStepCommonadDef_CreatedBy] [decimal](18, 0) NULL,
	[RuStepCommonadDef_CreatedOn] [datetime] NULL,
	[RuStepCommonadDef_ModifiedBy] [decimal](18, 0) NULL,
	[RuStepCommonadDef_ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_RuStepCommonadDef] PRIMARY KEY CLUSTERED 
(
	[RuStepCommonadDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
