/****** Object:  UserDefinedTableType [dbo].[MtBilateralContract_UDT_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtBilateralContract_UDT_Interface] AS TABLE(
	[MtBilateralContract_Date] [nvarchar](max) NULL,
	[MtBilateralContract_Hour] [nvarchar](max) NULL,
	[MtBilateralContract_ContractId] [nvarchar](max) NULL,
	[MtBilateralContract_SellerMPId] [nvarchar](max) NULL,
	[MtBilateralContract_BuyerMPId] [nvarchar](max) NULL,
	[MtBilateralContract_ContractType] [varchar](100) NULL,
	[MtBilateralContract_MeterOwnerMPId] [nvarchar](max) NULL,
	[MtBilateralContract_CDPID] [varchar](100) NULL,
	[MtBilateralContract_Percentage] [nvarchar](max) NULL,
	[MtBilateralContract_ContractedQuantity] [nvarchar](max) NULL,
	[MtBilateralContract_CapQuantity] [nvarchar](max) NULL,
	[MtBilateralContract_AncillaryServices] [varchar](100) NULL,
	[MtBilateralContract_DistributionLosses] [varchar](100) NULL,
	[MtBilateralContract_TransmissionLoss] [varchar](100) NULL,
	[BuyerSrCategory_Code] [varchar](4) NULL,
	[SellerSrCategory_Code] [varchar](4) NULL,
	[MtBilateralContract_Message] [nvarchar](max) NULL,
	[MtAvailibilityData_IsValid] [bit] NULL,
	[SrContractSubType_Name] [nvarchar](max) NULL
)
