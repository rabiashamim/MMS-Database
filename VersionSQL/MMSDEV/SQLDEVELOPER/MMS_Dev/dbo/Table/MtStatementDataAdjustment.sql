/****** Object:  Table [dbo].[MtStatementDataAdjustment]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtStatementDataAdjustment(
	[MtStatementDataAdjustment_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[StatementDataAdjustment_StatementRefernce_Id] [decimal](18, 0) NOT NULL,
	[StatementDataAdjustment_StatementDefName] [varchar](50) NULL,
	[StatementDataAdjustment_Month] [int] NOT NULL,
	[StatementDataAdjustment_Year] [int] NOT NULL,
	[StatementDataAdjustment_Ref_Month] [int] NOT NULL,
	[StatementDataAdjustment_Ref_Year] [int] NOT NULL,
	[StatementDataAdjustment_MPID] [decimal](18, 0) NULL,
	[StatementDataAdjustment_AdjustmentType] [varchar](20) NULL,
	[StatementDataAdjustment_Adjustment] [decimal](25, 13) NULL,
	[StatementDataAdjustment_CreatedBy] [int] NOT NULL,
	[StatementDataAdjustment_CreatedOn] [datetime] NOT NULL,
	[StatementDataAdjustment_IsDeleted] [bit] NULL
) ON [PRIMARY]
