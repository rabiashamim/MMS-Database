/****** Object:  Table [dbo].[BmeStatementDataMpMonthly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataMpMonthly_SettlementProcess](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NULL,
	[BmeStatementData_ImbalanceCharges] [decimal](25, 13) NULL,
	[BmeStatementData_SettlementOfLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_AmountPayableReceivable] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedActual] [decimal](25, 13) NULL,
	[BmeStatementData_IsPowerPool] [bit] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_ESSAdjustment] [decimal](25, 13) NULL
) ON [PRIMARY]
