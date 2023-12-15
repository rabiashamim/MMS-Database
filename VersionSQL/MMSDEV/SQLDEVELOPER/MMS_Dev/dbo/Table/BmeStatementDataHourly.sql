/****** Object:  Table [dbo].[BmeStatementDataHourly]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BmeStatementDataHourly(
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_TransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_DemandedEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_UpliftTransmissionLosses] [decimal](38, 24) NULL,
	[BmeStatementData_ActualCapacity] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGenerated] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImported] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGeneratedLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImportedLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_CAPLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_BmeStatementDataHourly] PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_NtdcDateTime] ASC,
	[BmeStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
