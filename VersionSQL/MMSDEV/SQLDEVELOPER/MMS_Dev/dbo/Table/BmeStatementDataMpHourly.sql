/****** Object:  Table [dbo].[BmeStatementDataMpHourly]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataMpHourly](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_AdjustedEnergy] [decimal](18, 0) NULL,
	[BmeStatementData_TransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_DemandedEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_UpliftTransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_ActualEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedActual] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGenerated] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImport] [decimal](25, 13) NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NOT NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NOT NULL,
	[BmeStatementData_AdjustedEnergyImport] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyExport] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGeneratedLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImportedLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_CAPLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedImported] [decimal](25, 13) NULL,
	[BmeStatementData_ActualCapacity] [decimal](25, 13) NULL,
	[BmeStatementData_EnergyTradedBought] [decimal](25, 13) NULL,
	[BmeStatementData_EnergyTradedSold] [decimal](25, 13) NULL,
	[BmeStatementData_EnergyTraded] [decimal](25, 13) NULL,
	[BmeStatementData_Imbalance] [decimal](25, 13) NULL,
	[BmeStatementData_ImbalanceCharges] [decimal](25, 13) NULL,
	[BmeStatementData_MarginalPrice] [decimal](25, 13) NULL,
	[BmeStatementData_BSUPRatioPP] [decimal](25, 13) NULL,
	[BmeStatementData_IsPowerPool] [bit] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[BmeStatementData_ActualEnergy_Metered] [decimal](25, 13) NULL,
 CONSTRAINT [PK_BmeStatementDataMpHourly] PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_NtdcDateTime] ASC,
	[BmeStatementData_PartyRegisteration_Id] ASC,
	[BmeStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
