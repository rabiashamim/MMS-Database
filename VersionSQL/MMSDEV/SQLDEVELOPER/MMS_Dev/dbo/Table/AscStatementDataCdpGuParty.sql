/****** Object:  Table [dbo].[AscStatementDataCdpGuParty]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AscStatementDataCdpGuParty](
	[AscStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[AscStatementData_GuPartyRegisteration_Id] [int] NOT NULL,
	[AscStatementData_GuPartyRegisteration_Name] [nvarchar](200) NOT NULL,
	[AscStatementData_GuPartyCategory_Code] [nvarchar](50) NOT NULL,
	[AscStatementData_GuPartyType_Code] [nvarchar](50) NOT NULL,
	[AscStatementData_CdpId] [varchar](100) NOT NULL,
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
	[AscStatementData_SOUnitId] [int] NOT NULL,
	[AscStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[AscStatementData_CongestedZoneId] [int] NULL,
	[AscStatementData_CongestedZone] [nvarchar](50) NULL,
 CONSTRAINT [PK_AscStatementDataCdpGuParty] PRIMARY KEY CLUSTERED 
(
	[AscStatementData_StatementProcessId] ASC,
	[AscStatementData_GuPartyRegisteration_Id] ASC,
	[AscStatementData_CdpId] ASC,
	[AscStatementData_SOUnitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
