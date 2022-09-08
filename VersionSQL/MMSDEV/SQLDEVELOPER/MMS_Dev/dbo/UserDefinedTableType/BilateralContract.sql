/****** Object:  UserDefinedTableType [dbo].[BilateralContract]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[BilateralContract] AS TABLE(
	[Date] [date] NULL,
	[Hours] [int] NULL,
	[ContractId] [decimal](18, 0) NULL,
	[SellerMPId] [decimal](18, 0) NULL,
	[BuyerMPId] [decimal](18, 0) NULL,
	[ContractType] [varchar](100) NULL,
	[MeterOwnerMPId] [decimal](18, 0) NULL,
	[CDPID] [varchar](100) NULL,
	[Percentage] [decimal](18, 2) NULL,
	[ContractedQuantity] [decimal](18, 2) NULL,
	[CapQuantity] [decimal](18, 2) NULL,
	[AncillaryServices] [varchar](100) NULL,
	[DistributionLosses] [varchar](100) NULL,
	[TransmissionLoss] [varchar](100) NULL,
	[BuyerSrCategory_Code] [varchar](100) NULL,
	[SellerSrCategory_Code] [varchar](100) NULL
)
