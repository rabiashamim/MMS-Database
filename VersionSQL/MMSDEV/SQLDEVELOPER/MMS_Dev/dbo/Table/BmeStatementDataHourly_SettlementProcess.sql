/****** Object:  Table [dbo].[BmeStatementDataHourly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataHourly_SettlementProcess](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_TransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_DemandedEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_UpliftTransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_ActualCapacity] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGenerated] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImported] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGeneratedLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImportedLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_CAPLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL
) ON [PRIMARY]
