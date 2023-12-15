/****** Object:  Table [dbo].[BmeStatementDataGenUnitHourly]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BmeStatementDataGenUnitHourly(
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_MtGenerator_Id] [decimal](18, 0) NULL,
	[BmeStatementData_MtGeneratorUnit_Id] [decimal](18, 0) NULL,
	[BmeStatementData_SOUnitId] [int] NULL,
	[SrTechnologyType_Code] [varchar](4) NULL,
	[BmeStatementData_InstalledCapacity_KW] [decimal](18, 4) NULL,
	[BmeStatementData_IncEnergyExport] [decimal](25, 13) NULL,
	[BmeStatementData_IncEnergyImport] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyExport] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyImport] [decimal](25, 13) NULL,
	[BmeStatementData_GenerationUnitEnergy] [decimal](25, 13) NULL,
	[BmeStatementData_GenerationUnitWiseBackfeed] [decimal](25, 13) NULL,
	[BmeStatementData_GenerationUnitEnergy_Metered] [decimal](25, 13) NULL,
	[BmeStatementData_GenerationUnitWiseBackfeed_Metered] [decimal](25, 13) NULL,
	[BmeStatementData_AvailableCapacityASC] [decimal](20, 4) NULL,
	[BmeStatementData_CalculatedAvailableCapacityASC] [decimal](20, 4) NULL,
	[BmeStatementData_ActualCapacity] [decimal](20, 4) NULL,
	[BmeStatementData_GenCapacity] [decimal](20, 4) NULL,
	[BmeStatementData_UnitWiseGeneration] [decimal](20, 4) NULL,
	[BmeStatementData_UnitWiseGenerationBackFeed] [decimal](20, 4) NULL,
	[BmeStatementData_UnitWiseGeneration_Metered] [decimal](20, 4) NULL,
	[BmeStatementData_UnitWiseGenerationBackFeed_Metered] [decimal](20, 4) NULL,
	[BmeStatementData_IsBackfeedInclude] [bit] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[MtAvailibilityData_AvailableCapacityASCSum] [decimal](30, 18) NULL,
	[BmeStatementData_CalculatedAvailableCapacityASCSum] [decimal](20, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
