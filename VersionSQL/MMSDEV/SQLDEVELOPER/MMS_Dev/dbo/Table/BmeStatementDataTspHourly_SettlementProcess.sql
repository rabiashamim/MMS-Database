/****** Object:  Table [dbo].[BmeStatementDataTspHourly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataTspHourly_SettlementProcess](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NULL,
	[BmeStatementData_PartyCategory_Code] [varchar](4) NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NULL,
	[BmeStatementData_AdjustedEnergyImport] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyExport] [decimal](25, 13) NULL,
	[BmeStatementData_TransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL
) ON [PRIMARY]
