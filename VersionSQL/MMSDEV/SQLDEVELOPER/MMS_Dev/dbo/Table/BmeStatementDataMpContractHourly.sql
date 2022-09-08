/****** Object:  Table [dbo].[BmeStatementDataMpContractHourly]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataMpContractHourly](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_SellerPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[BmeStatementData_SellerPartyRegisteration_Name] [nvarchar](200) NOT NULL,
	[BmeStatementData_SellerPartyType_Code] [varchar](4) NOT NULL,
	[BmeStatementData_BuyerPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[BmeStatementData_BuyerPartyRegisteration_Name] [nvarchar](200) NOT NULL,
	[BmeStatementData_BuyerPartyType_Code] [varchar](4) NOT NULL,
	[BmeStatementData_EnergyTradedBought] [decimal](25, 13) NULL,
	[BmeStatementData_EnergyTradedSold] [decimal](25, 13) NULL,
	[BmeStatementData_ContractId] [decimal](18, 0) NOT NULL,
	[BmeStatementData_ContractType] [nvarchar](100) NULL,
	[BmeStatementData_Percentage] [decimal](25, 13) NULL,
	[BmeStatementData_ContractedQuantity] [decimal](25, 13) NULL,
	[BmeStatementData_CapQuantity] [decimal](25, 13) NULL,
	[BmeStatementData_AncillaryServices] [nvarchar](50) NULL,
	[BmeStatementData_ContractType_Id] [decimal](18, 0) NOT NULL,
	[BmeStatementData_ContractSubType_Id] [int] NOT NULL,
	[BmeStatementData_SellerPartyCategory_Code] [varchar](4) NOT NULL,
	[BmeStatementData_BuyerPartyCategory_Code] [varchar](4) NOT NULL,
	[BmeStatementData_CongestedZoneID] [int] NOT NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[BmeStatementData_CongestedZone] [nvarchar](50) NULL,
 CONSTRAINT [PK_BmeStatementDataMpContractHourly] PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_NtdcDateTime] ASC,
	[BmeStatementData_StatementProcessId] ASC,
	[BmeStatementData_ContractId] ASC,
	[BmeStatementData_CongestedZoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
