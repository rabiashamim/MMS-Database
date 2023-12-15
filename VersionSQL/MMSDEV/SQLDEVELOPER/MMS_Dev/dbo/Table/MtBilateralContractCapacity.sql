/****** Object:  Table [dbo].[MtBilateralContractCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtBilateralContractCapacity(
	[MtBilateralContractCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NULL,
	[MtBilateralContractCapacity_RowNumber] [bigint] NULL,
	[MtBilateralContractCapacity_Date] [date] NULL,
	[MtContractRegistration_SellerId] [decimal](18, 0) NULL,
	[MtContractRegistration_BuyerId] [decimal](18, 0) NULL,
	[MtContractRegistration_BuyerCategoryId] [decimal](18, 0) NULL,
	[MtContractRegistration_SellerCategoryId] [decimal](18, 0) NULL,
	[SrContractType_Id] [int] NULL,
	[MtBilateralContractCapacity_IsGuarenteed] [bit] NULL,
	[MtBilateralContractCapacity_Percentage] [decimal](18, 2) NULL,
	[MtBilateralContractCapacity_ContractedQuantity] [decimal](18, 2) NULL,
	[MtBilateralContractCapacity_CapQuantity] [decimal](18, 2) NULL,
	[MtBilateralContractCapacity_CreatedBy] [int] NOT NULL,
	[MtBilateralContractCapacity_CreatedOn] [datetime] NOT NULL,
	[MtBilateralContractCapacity_ModifiedBy] [int] NULL,
	[MtBilateralContractCapacity_ModifiedOn] [datetime] NULL,
	[MtBilateralContractCapacity_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtBilateralContractCapacity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtBilateralContractCapacity  WITH CHECK ADD FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtBilateralContractCapacity  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
