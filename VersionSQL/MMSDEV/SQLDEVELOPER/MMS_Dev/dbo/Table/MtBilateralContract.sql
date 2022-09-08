/****** Object:  Table [dbo].[MtBilateralContract]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtBilateralContract](
	[MtBilateralContract_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtBilateralContract_Date] [date] NOT NULL,
	[MtBilateralContract_Hour] [int] NOT NULL,
	[MtBilateralContract_ContractId] [decimal](18, 0) NOT NULL,
	[MtBilateralContract_SellerMPId] [decimal](18, 0) NOT NULL,
	[MtBilateralContract_BuyerMPId] [decimal](18, 0) NOT NULL,
	[MtBilateralContract_ContractType] [varchar](100) NULL,
	[MtBilateralContract_MeterOwnerMPId] [decimal](18, 0) NULL,
	[MtBilateralContract_CDPID] [varchar](100) NOT NULL,
	[MtBilateralContract_Percentage] [decimal](18, 2) NULL,
	[MtBilateralContract_ContractedQuantity] [decimal](18, 2) NULL,
	[MtBilateralContract_CapQuantity] [decimal](18, 2) NULL,
	[MtBilateralContract_AncillaryServices] [varchar](100) NULL,
	[MtBilateralContract_DistributionLosses] [varchar](100) NULL,
	[MtBilateralContract_TransmissionLoss] [varchar](100) NULL,
	[MtBilateralContract_CreatedBy] [int] NOT NULL,
	[MtBilateralContract_CreatedOn] [datetime] NOT NULL,
	[MtBilateralContract_ModifiedBy] [int] NULL,
	[MtBilateralContract_ModifiedOn] [datetime] NULL,
	[MtBilateralContract_Deleted] [bit] NULL,
	[SrContractType_Id] [int] NULL,
	[ContractSubType_Id] [int] NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
	[BuyerSrCategory_Code] [varchar](4) NULL,
	[SellerSrCategory_Code] [varchar](4) NULL,
	[RuCDPDetail_CongestedZoneID] [int] NOT NULL,
	[RuCDPDetail_TaxZoneID] [int] NULL,
	[MtBilateralContract_RowNumber] [bigint] NULL,
 CONSTRAINT [PK__MtBilate__80A0258165BFEF39] PRIMARY KEY CLUSTERED 
(
	[MtBilateralContract_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtBilateralContract] ADD  CONSTRAINT [DF_MtBilateralContract_SrContractType_Id]  DEFAULT ((1)) FOR [SrContractType_Id]
ALTER TABLE [dbo].[MtBilateralContract] ADD  CONSTRAINT [DF_MtBilateralContract_ContractSubType_Id]  DEFAULT ((0)) FOR [ContractSubType_Id]
ALTER TABLE [dbo].[MtBilateralContract] ADD  CONSTRAINT [DF_MtBilateralContract_RuCDPDetail_CongestedZoneID]  DEFAULT ((1)) FOR [RuCDPDetail_CongestedZoneID]
