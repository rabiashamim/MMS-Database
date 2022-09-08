/****** Object:  Table [dbo].[MtStatementProcessSteps]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtStatementProcessSteps](
	[MtStatementProcessSteps_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcessSteps_Status] [bit] NULL,
	[MtStatementProcessSteps_Description] [varchar](100) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
	[RuStepDef_ID] [decimal](18, 0) NULL,
	[MtStatementProcessSteps_CreatedBy] [int] NULL,
	[MtStatementProcessSteps_CreatedOn] [datetime] NULL,
	[MtStatementProcessSteps_ModifiedBy] [int] NULL,
	[MtStatementProcessSteps_ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_MtStatementProcessSteps] PRIMARY KEY CLUSTERED 
(
	[MtStatementProcessSteps_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
