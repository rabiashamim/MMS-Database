/****** Object:  Table [dbo].[MtBilateralContract_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtBilateralContract_Interface](
	[MtBilateralContract_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtBilateralContract_RowNumber] [bigint] NULL,
	[MtBilateralContract_Date] [nvarchar](max) NULL,
	[MtBilateralContract_Hour] [nvarchar](max) NULL,
	[MtBilateralContract_ContractId] [nvarchar](max) NULL,
	[MtBilateralContract_SellerMPId] [nvarchar](max) NULL,
	[MtBilateralContract_BuyerMPId] [nvarchar](max) NULL,
	[MtBilateralContract_ContractType] [nvarchar](max) NULL,
	[MtBilateralContract_MeterOwnerMPId] [nvarchar](max) NULL,
	[MtBilateralContract_CDPID] [nvarchar](max) NULL,
	[MtBilateralContract_Percentage] [nvarchar](max) NULL,
	[MtBilateralContract_ContractedQuantity] [nvarchar](max) NULL,
	[MtBilateralContract_CapQuantity] [nvarchar](max) NULL,
	[MtBilateralContract_AncillaryServices] [varchar](100) NULL,
	[MtBilateralContract_DistributionLosses] [varchar](100) NULL,
	[MtBilateralContract_TransmissionLoss] [varchar](100) NULL,
	[MtBilateralContract_CreatedBy] [int] NOT NULL,
	[MtBilateralContract_CreatedOn] [datetime] NOT NULL,
	[MtBilateralContract_ModifiedBy] [int] NULL,
	[MtBilateralContract_ModifiedOn] [datetime] NULL,
	[MtBilateralContract_Deleted] [bit] NULL,
	[SrContractType_Id] [nvarchar](max) NULL,
	[ContractSubType_Id] [nvarchar](max) NULL,
	[BmeStatementData_NtdcDateTime] [nvarchar](max) NULL,
	[BuyerSrCategory_Code] [varchar](4) NULL,
	[SellerSrCategory_Code] [varchar](4) NULL,
	[RuCDPDetail_CongestedZoneID] [nvarchar](max) NULL,
	[RuCDPDetail_TaxZoneID] [nvarchar](max) NULL,
	[MtBilateralContract_Message] [nvarchar](max) NULL,
	[MtBilateralContract_IsValid] [nvarchar](max) NULL,
 CONSTRAINT [PK__MtBilate__80A0258165BFEF39Interface] PRIMARY KEY CLUSTERED 
(
	[MtBilateralContract_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
