/****** Object:  Table [dbo].[BmeStatementDataMpCategoryMonthly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataMpCategoryMonthly_SettlementProcess](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_EnergySuppliedActual] [decimal](25, 13) NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NULL,
	[BmeStatementData_PartyCategory_Code] [varchar](4) NULL,
	[BmeStatementData_IsPowerPool] [bit] NULL,
	[BmeStatementData_CongestedZoneID] [int] NULL,
	[BmeStatementData_ES] [decimal](25, 13) NULL,
	[BmeStatementData_MAC] [decimal](25, 13) NULL,
	[BmeStatementData_IG_AC] [decimal](25, 13) NULL,
	[BmeStatementData_RG_AC] [decimal](25, 13) NULL,
	[BmeStatementData_GS_SC] [decimal](25, 13) NULL,
	[BmeStatementData_GBS_BSC] [decimal](25, 13) NULL,
	[BmeStatementData_TAC] [decimal](25, 13) NULL,
	[BmeStatementData_MRC] [decimal](25, 13) NULL,
	[BmeStatementData_TC] [decimal](25, 13) NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_CongestedZone] [nvarchar](50) NULL,
	[BmeStatementData_ET] [decimal](25, 13) NULL
) ON [PRIMARY]
