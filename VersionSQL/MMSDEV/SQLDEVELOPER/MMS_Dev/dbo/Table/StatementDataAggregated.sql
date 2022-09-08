/****** Object:  Table [dbo].[StatementDataAggregated]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[StatementDataAggregated](
	[StatementDataAggregated_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[StatementDataAggregated_Month] [int] NULL,
	[StatementDataAggregated_Year] [int] NULL,
	[SrStatementDef_ID] [int] NULL,
	[SrProcessDef_ID] [int] NULL,
	[LuAccountingMonth_Id] [int] NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
	[StatementDataAggregated_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[StatementDataAggregated_PartyName] [nvarchar](200) NULL,
	[StatementDataAggregated_BmeStatementData_AmountPayableReceivable] [decimal](32, 16) NULL,
	[StatementDataAggregated_AscStatementData_PAYABLE] [decimal](32, 16) NULL,
	[StatementDataAggregated_AscStatementData_RECEIVABLE] [decimal](32, 16) NULL,
	[StatementDataAggregated_AdjustmentESS_ProcessId] [decimal](18, 0) NULL,
	[StatementDataAggregated_AdjustmentESS_ProcessName] [nvarchar](100) NULL,
	[StatementDataAggregated_AdjustmentESS_LuAccountingMonth_Id] [int] NULL,
	[StatementDataAggregated_AdjustmentESS_Amount] [decimal](32, 16) NULL,
	[StatementDataAggregated_NetAmount] [decimal](32, 16) NULL,
	[StatementDataAggregated_CreatedBy] [int] NOT NULL,
	[StatementDataAggregated_CreatedOn] [datetime] NOT NULL,
	[StatementDataAggregated_ModifiedBy] [int] NULL,
	[StatementDataAggregated_ModifiedOn] [datetime] NULL,
	[StatementDataAggregated_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[StatementDataAggregated_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
