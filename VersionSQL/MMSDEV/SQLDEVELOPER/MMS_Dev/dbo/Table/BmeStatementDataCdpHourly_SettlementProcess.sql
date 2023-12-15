﻿/****** Object:  Table [dbo].[BmeStatementDataCdpHourly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BmeStatementDataCdpHourly_SettlementProcess(
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_CdpId] [varchar](100) NULL,
	[BmeStatementData_MeterIdImport] [decimal](18, 0) NULL,
	[BmeStatementData_IncEnergyImport] [decimal](25, 13) NOT NULL,
	[BmeStatementData_DataSourceImport] [varchar](50) NULL,
	[BmeStatementData_MeterIdExport] [decimal](18, 0) NULL,
	[BmeStatementData_IncEnergyExport] [decimal](25, 13) NOT NULL,
	[BmeStatementData_DataSourceExport] [varchar](50) NULL,
	[BmeStatementData_CreatedBy] [decimal](18, 0) NULL,
	[BmeStatementData_CreatedOn] [datetime] NULL,
	[BmeStatementData_ModifiedBy] [decimal](18, 0) NULL,
	[BmeStatementData_ModifiedOn] [datetime] NULL,
	[BmeStatementData_LineVoltage] [decimal](18, 4) NULL,
	[BmeStatementData_FromPartyRegisteration_Id] [int] NULL,
	[BmeStatementData_FromPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_FromPartyCategory_Code] [nvarchar](50) NULL,
	[BmeStatementData_FromPartyType_Code] [nvarchar](50) NULL,
	[BmeStatementData_DistLosses_Factor] [decimal](18, 0) NULL,
	[BmeStatementData_DistLosses_EffectiveFrom] [datetime] NULL,
	[BmeStatementData_DistLosses_EffectiveTo] [datetime] NULL,
	[BmeStatementData_ToPartyRegisteration_Id] [int] NULL,
	[BmeStatementData_ToPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_ToPartyCategory_Code] [nvarchar](50) NULL,
	[BmeStatementData_ToPartyType_Code] [nvarchar](50) NULL,
	[BmeStatementData_AdjustedEnergy] [decimal](18, 0) NULL,
	[BmeStatementData_TransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_DemandedEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyExport] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyImport] [decimal](25, 13) NULL,
	[BmeStatementData_ActualEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedGenerated] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedActual] [decimal](25, 13) NULL,
	[BmeStatementData_IsEnergyImported] [bit] NULL,
	[BmeStatementData_OwnerId] [decimal](18, 0) NULL,
	[BmeStatementData_ISARE] [bit] NULL,
	[BmeStatementData_ISThermal] [bit] NULL,
	[BmeStatementData_RuCDPDetail_Id] [decimal](18, 0) NULL,
	[BmeStatementData_IsLegacy] [bit] NULL,
	[BmeStatementData_EnergySuppliedImported] [decimal](25, 13) NULL,
	[BmeStatementData_CongestedZoneID] [int] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_CongestedZone] [nvarchar](50) NULL,
	[IsBackfeedInclude] [bit] NOT NULL,
	[BmeStatementData_IsActualGenerationUnit] [bit] NULL
) ON [PRIMARY]

ALTER TABLE dbo.BmeStatementDataCdpHourly_SettlementProcess ADD  DEFAULT ((1)) FOR [IsBackfeedInclude]
ALTER TABLE dbo.BmeStatementDataCdpHourly_SettlementProcess ADD  DEFAULT ((0)) FOR [BmeStatementData_IsActualGenerationUnit]
