/****** Object:  Table [dbo].[BMEContractedAmounts_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BMEContractedAmounts_SettlementProcess](
	[BMEContract_ContractId] [decimal](18, 0) NULL,
	[BMEContract_SellerPartyId] [decimal](18, 0) NULL,
	[BMEContract_SellerPartyName] [varchar](500) NULL,
	[BMEContract_SellerPartyType_Code] [varchar](4) NULL,
	[BMEContract_BuyerPartyId] [decimal](18, 0) NULL,
	[BMEContract_BuyerPartyName] [varchar](500) NULL,
	[BMEContract_BuyerPartyType_Code] [varchar](4) NULL,
	[BMEContract_ContractType] [varchar](100) NULL,
	[BMEContract_SrContractType_Id] [decimal](18, 0) NULL,
	[BMEContract_ContractDay] [int] NULL,
	[BMEContract_ContractHour] [int] NULL,
	[BMEContract_EnergyTradedBought] [decimal](18, 4) NULL,
	[BMEContract_EnergyTradedSold] [decimal](18, 4) NULL,
	[BMEContract_EnergyTraded] [decimal](18, 4) NULL,
	[BMEContract_SettlementProcessId] [decimal](18, 4) NULL
) ON [PRIMARY]
