/****** Object:  Table [dbo].[BmeStatementDataCdpOwnerParty]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataCdpOwnerParty](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_OwnerPartyRegisteration_Id] [int] NOT NULL,
	[BmeStatementData_OwnerPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_OwnerPartyCategory_Code] [nvarchar](50) NULL,
	[BmeStatementData_OwnerPartyType_Code] [nvarchar](50) NULL,
	[BmeStatementData_CdpId] [varchar](100) NOT NULL,
	[BmeStatementData_FromPartyRegisteration_Id] [int] NULL,
	[BmeStatementData_FromPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_FromPartyCategory_Code] [nvarchar](50) NULL,
	[BmeStatementData_FromPartyType_Code] [nvarchar](50) NULL,
	[BmeStatementData_ToPartyRegisteration_Id] [int] NULL,
	[BmeStatementData_ToPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_ToPartyCategory_Code] [nvarchar](50) NULL,
	[BmeStatementData_ToPartyType_Code] [nvarchar](50) NULL,
	[BmeStatementData_ISARE] [bit] NULL,
	[BmeStatementData_ISThermal] [bit] NULL,
	[BmeStatementData_RuCDPDetail_Id] [decimal](18, 0) NULL,
	[BmeStatementData_IsLegacy] [bit] NULL,
	[BmeStatementData_IsEnergyImported] [bit] NULL,
	[BmeStatementData_IsPowerPool] [bit] NULL,
	[BmeStatementData_CongestedZoneID] [int] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[BmeStatementData_CongestedZone] [nvarchar](50) NULL,
 CONSTRAINT [PK_BmeStatementDataCdpOwnerParty] PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_CdpId] ASC,
	[BmeStatementData_StatementProcessId] ASC,
	[BmeStatementData_OwnerPartyRegisteration_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
