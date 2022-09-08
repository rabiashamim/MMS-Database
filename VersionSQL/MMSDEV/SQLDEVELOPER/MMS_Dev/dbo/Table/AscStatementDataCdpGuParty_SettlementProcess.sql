/****** Object:  Table [dbo].[AscStatementDataCdpGuParty_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AscStatementDataCdpGuParty_SettlementProcess](
	[AscStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[AscStatementData_GuPartyRegisteration_Id] [int] NULL,
	[AscStatementData_GuPartyRegisteration_Name] [nvarchar](200) NULL,
	[AscStatementData_GuPartyCategory_Code] [nvarchar](50) NULL,
	[AscStatementData_GuPartyType_Code] [nvarchar](50) NULL,
	[AscStatementData_CdpId] [varchar](100) NULL,
	[AscStatementData_FromPartyRegisteration_Id] [int] NULL,
	[AscStatementData_FromPartyRegisteration_Name] [nvarchar](200) NULL,
	[AscStatementData_FromPartyCategory_Code] [nvarchar](50) NULL,
	[AscStatementData_FromPartyType_Code] [nvarchar](50) NULL,
	[AscStatementData_ToPartyRegisteration_Id] [int] NULL,
	[AscStatementData_ToPartyRegisteration_Name] [nvarchar](200) NULL,
	[AscStatementData_ToPartyCategory_Code] [nvarchar](50) NULL,
	[AscStatementData_ToPartyType_Code] [nvarchar](50) NULL,
	[AscStatementData_ISARE] [bit] NULL,
	[AscStatementData_ISThermal] [bit] NULL,
	[AscStatementData_RuCDPDetail_Id] [decimal](18, 0) NULL,
	[AscStatementData_IsLegacy] [bit] NULL,
	[AscStatementData_IsEnergyImported] [bit] NULL,
	[AscStatementData_IsPowerPool] [bit] NULL,
	[AscStatementData_GenerationUnit_Id] [decimal](18, 0) NULL,
	[AscStatementData_Generator_Id] [decimal](18, 0) NULL,
	[AscStatementData_SOUnitId] [int] NULL,
	[AscStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[AscStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[AscStatementData_CongestedZoneId] [int] NULL,
	[AscStatementData_CongestedZone] [nvarchar](50) NULL
) ON [PRIMARY]
