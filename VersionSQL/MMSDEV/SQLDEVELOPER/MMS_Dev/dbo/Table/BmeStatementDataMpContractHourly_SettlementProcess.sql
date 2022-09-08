/****** Object:  Table [dbo].[BmeStatementDataMpContractHourly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataMpContractHourly_SettlementProcess](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_SellerPartyRegisteration_Id] [decimal](18, 0) NULL,
	[BmeStatementData_SellerPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_SellerPartyType_Code] [varchar](4) NULL,
	[BmeStatementData_BuyerPartyRegisteration_Id] [decimal](18, 0) NULL,
	[BmeStatementData_BuyerPartyRegisteration_Name] [nvarchar](200) NULL,
	[BmeStatementData_BuyerPartyType_Code] [varchar](4) NULL,
	[BmeStatementData_EnergyTradedBought] [decimal](25, 13) NULL,
	[BmeStatementData_EnergyTradedSold] [decimal](25, 13) NULL,
	[BmeStatementData_ContractId] [decimal](18, 0) NULL,
	[BmeStatementData_ContractType] [nvarchar](100) NULL,
	[BmeStatementData_Percentage] [decimal](25, 13) NULL,
	[BmeStatementData_ContractedQuantity] [decimal](25, 13) NULL,
	[BmeStatementData_CapQuantity] [decimal](25, 13) NULL,
	[BmeStatementData_AncillaryServices] [nvarchar](50) NULL,
	[BmeStatementData_ContractType_Id] [decimal](18, 0) NULL,
	[BmeStatementData_ContractSubType_Id] [int] NULL,
	[BmeStatementData_SellerPartyCategory_Code] [varchar](4) NULL,
	[BmeStatementData_BuyerPartyCategory_Code] [varchar](4) NULL,
	[BmeStatementData_CongestedZoneID] [int] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[BmeStatementData_CongestedZone] [nvarchar](50) NULL
) ON [PRIMARY]
