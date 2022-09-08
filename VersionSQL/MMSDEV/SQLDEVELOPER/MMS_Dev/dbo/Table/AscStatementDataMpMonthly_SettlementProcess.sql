/****** Object:  Table [dbo].[AscStatementDataMpMonthly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AscStatementDataMpMonthly_SettlementProcess](
	[AscStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[AscStatementData_Year] [int] NOT NULL,
	[AscStatementData_Month] [int] NOT NULL,
	[AscStatementData_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[AscStatementData_PartyName] [nvarchar](200) NULL,
	[AscStatementData_PartyType_Code] [varchar](4) NULL,
	[AscStatementData_MRC] [decimal](25, 13) NULL,
	[AscStatementData_RG_AC] [decimal](25, 13) NULL,
	[AscStatementData_IG_AC] [decimal](25, 13) NULL,
	[AscStatementData_SC_BSC] [decimal](25, 13) NULL,
	[AscStatementData_MAC] [decimal](25, 13) NULL,
	[AscStatementData_GS_SC] [decimal](25, 13) NULL,
	[AscStatementData_GBS_BSC] [decimal](25, 13) NULL,
	[AscStatementData_PAYABLE] [decimal](25, 13) NULL,
	[AscStatementData_RECEIVABLE] [decimal](25, 13) NULL,
	[AscStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[AscStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[AscStatementData_AdjustmentPAYABLE] [decimal](25, 13) NULL,
	[AscStatementData_AdjustmentRECEIVABLE] [decimal](25, 13) NULL
) ON [PRIMARY]
